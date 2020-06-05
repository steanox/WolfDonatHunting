//
//  Level1Scene.swift
//  3DGameSceneKit
//
//  Created by octavianus on 25/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import SceneKit
import Foundation

enum MovementDirection{
    case left,right
}


class Level1Scene: SCNScene {
    private let velocityMultiplier: CGFloat = 0.0016
    private let levelWidth = 320
    private let levelLength = 640
    private let numberOfRings = 100
    
    static let DefaultCameraTransitionDuration = 1.0
    static let CameraOrientationSensitivity: Float = 0.05
    
    private var terrain: RBTerrain!
    private var _player: Player?
    
    // Camera and targets
    private var cameraNode = SCNNode()
    private var lookAtTarget = SCNNode()
    private var lastActiveCamera: SCNNode?
    private var lastActiveCameraFrontDirection = simd_float3.zero
    private var activeCamera: SCNNode?
    
    
    var hud: HUD?
    
    var touchedRing: Int = 0
    
    var cameraDirection = vector_float2.zero {
        didSet {
            let l = simd_length(cameraDirection)
            if l > 1.0 {
                cameraDirection *= 1 / l
            }
            cameraDirection.y = 0
        }
    }
    
    func createLevel() {
        addTerrain()
        addPlayer()
        spawnRings()
        setupCamera()
        self.physicsWorld.contactDelegate = self
    }
    
    func update(atTime: TimeInterval) {
        
    }
    
    func updatePlayerPosition(_ joystickData: AnalogJoystickData){
        _player?.updateWolfPosition(joyStickData: joystickData,velocityMultiplier: self.velocityMultiplier)
    }
    
    func updatePlayerState(_ state: WolfState){
        _player?.changeWolfState(state)
    }
    
    
    func addTerrain(){
        terrain = RBTerrain(width: levelWidth, length: levelLength, scale: 200)
        let generator = RBPerlinNoiseGenerator(seed: nil)
         terrain.formula = {(x: Int32, y: Int32) in
             return generator.valueFor(x: x, y: y)
         }

        terrain.create(withColor: UIColor.green)
        terrain.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        terrain.position = SCNVector3Make(0, -5, 0)
        self.rootNode.addChildNode(terrain)
    }
    
    private func addPlayer() {
        _player = Player()
        _player!.position = SCNVector3(160, 0, 0)
        self.rootNode.addChildNode(_player!)
    }
    
    public func move(_ direction: MovementDirection){
        self._player?.move(direction)
    }
    
    func collision(withRing ring: Ring){
        if ring.isHidden{
            return
        }
        
        ring.isHidden = true
        
        touchedRing += 1
        hud?.points = touchedRing
        
    }
    
    private func spawnRings(){
        let space = levelLength / (numberOfRings+1)
        
        for i in 1...numberOfRings{
            let ring = Ring()
            var x: CGFloat = 160
            
            let rnd = RBRandom.integer(1, 200)
            if rnd == 1{
                x = x - Player.moveOffset
            }else{
                x = x + Player.moveOffset
            }
            
            ring.position = SCNVector3(rnd,0,i*space)
            self.rootNode.addChildNode(ring)
        }
    }
    
    func setupCamera() {
        //The lookAtTarget node will be placed slighlty above the character using a constraint
        weak var weakSelf = self

        self.lookAtTarget.constraints = [ SCNTransformConstraint.positionConstraint(
                                        inWorldSpace: true, with: { (_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
            guard let strongSelf = weakSelf else { return position }

            var worldPosition = strongSelf._player!.simdWorldPosition
            worldPosition.y = strongSelf._player!.baseAltitude + 0.5
            return SCNVector3(worldPosition)
        })]

        self.rootNode.addChildNode(lookAtTarget)

        self.rootNode.enumerateHierarchy({(_ node: SCNNode, _ _: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.camera != nil {
                self.setupFollowCamera(node)
            }
        })

        self.cameraNode.camera = SCNCamera()
        self.cameraNode.name = "mainCamera"
        self.cameraNode.camera!.zNear = 0.1
        self.rootNode.addChildNode(cameraNode)

        setActiveCamera("camLookAt_cameraGame", animationDuration: 0.0)
    }
    
    func setupFollowCamera(_ cameraNode: SCNNode) {
        // look at "lookAtTarget"
        let lookAtConstraint = SCNLookAtConstraint(target: self.lookAtTarget)
        lookAtConstraint.influenceFactor = 0.07
        lookAtConstraint.isGimbalLockEnabled = true

        // distance constraints
        let follow = SCNDistanceConstraint(target: self.lookAtTarget)
        let distance = CGFloat(simd_length(cameraNode.simdPosition))
        follow.minimumDistance = distance
        follow.maximumDistance = distance

        // configure a constraint to maintain a constant altitude relative to the character
        let desiredAltitude = abs(cameraNode.simdWorldPosition.y)
        weak var weakSelf = self

        let keepAltitude = SCNTransformConstraint.positionConstraint(inWorldSpace: true, with: {(_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
                guard let strongSelf = weakSelf else { return position }
                var position = float3(position)
                position.y = strongSelf._player!.baseAltitude + desiredAltitude
                return SCNVector3( position )
            })

        let accelerationConstraint = SCNAccelerationConstraint()
        accelerationConstraint.maximumLinearVelocity = 1500.0
        accelerationConstraint.maximumLinearAcceleration = 50.0
        accelerationConstraint.damping = 0.05

        // use a custom constraint to let the user orbit the camera around the character
        let transformNode = SCNNode()
        let orientationUpdateConstraint = SCNTransformConstraint(inWorldSpace: true) { (_ node: SCNNode, _ transform: SCNMatrix4) -> SCNMatrix4 in
            guard let strongSelf = weakSelf else { return transform }
            if strongSelf.activeCamera != node {
                return transform
            }

            // Slowly update the acceleration constraint influence factor to smoothly reenable the acceleration.
            accelerationConstraint.influenceFactor = min(1, accelerationConstraint.influenceFactor + 0.01)

            let targetPosition = strongSelf.lookAtTarget.presentation.simdWorldPosition
            let cameraDirection = strongSelf.cameraDirection
            if cameraDirection.allZero() {
                return transform
            }

            // Disable the acceleration constraint.
            accelerationConstraint.influenceFactor = 0

            let characterWorldUp = strongSelf._player!.presentation.simdWorldUp

            transformNode.transform = transform

            let q = simd_mul(
                simd_quaternion(Level1Scene.CameraOrientationSensitivity * cameraDirection.x, characterWorldUp),
                simd_quaternion(Level1Scene.CameraOrientationSensitivity * cameraDirection.y, transformNode.simdWorldRight)
            )

            transformNode.simdRotate(by: q, aroundTarget: targetPosition)
            return transformNode.transform
        }

        cameraNode.constraints = [follow, keepAltitude, accelerationConstraint, orientationUpdateConstraint, lookAtConstraint]
    }
    
    func setActiveCamera(_ cameraName: String, animationDuration duration: CFTimeInterval) {
        guard let camera = self.rootNode.childNode(withName: cameraName, recursively: true) else { return }
        if self.activeCamera == camera {
            return
        }

        self.lastActiveCamera = activeCamera
        if activeCamera != nil {
            self.lastActiveCameraFrontDirection = (activeCamera?.presentation.simdWorldFront)!
        }
        self.activeCamera = camera

        // save old transform in world space
        let oldTransform: SCNMatrix4 = cameraNode.presentation.worldTransform

        // re-parent
        camera.addChildNode(cameraNode)

        // compute the old transform relative to our new parent node (yeah this is the complex part)
        let parentTransform = camera.presentation.worldTransform
        let parentInv = SCNMatrix4Invert(parentTransform)

        // with this new transform our position is unchanged in workd space (i.e we did re-parent but didn't move).
        cameraNode.transform = SCNMatrix4Mult(oldTransform, parentInv)

        // now animate the transform to identity to smoothly move to the new desired position
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        cameraNode.transform = SCNMatrix4Identity

        if let cameraTemplate = camera.camera {
            cameraNode.camera!.fieldOfView = cameraTemplate.fieldOfView
            cameraNode.camera!.wantsDepthOfField = cameraTemplate.wantsDepthOfField
            cameraNode.camera!.sensorHeight = cameraTemplate.sensorHeight
            cameraNode.camera!.fStop = cameraTemplate.fStop
            cameraNode.camera!.focusDistance = cameraTemplate.focusDistance
            cameraNode.camera!.bloomIntensity = cameraTemplate.bloomIntensity
            cameraNode.camera!.bloomThreshold = cameraTemplate.bloomThreshold
            cameraNode.camera!.bloomBlurRadius = cameraTemplate.bloomBlurRadius
            cameraNode.camera!.wantsHDR = cameraTemplate.wantsHDR
            cameraNode.camera!.wantsExposureAdaptation = cameraTemplate.wantsExposureAdaptation
            cameraNode.camera!.vignettingPower = cameraTemplate.vignettingPower
            cameraNode.camera!.vignettingIntensity = cameraTemplate.vignettingIntensity
        }
        SCNTransaction.commit()
    }

    func setActiveCamera(_ cameraName: String) {
        setActiveCamera(cameraName, animationDuration: Level1Scene.DefaultCameraTransitionDuration)
    }
}

extension Level1Scene: SCNPhysicsContactDelegate{
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if let ring = contact.nodeB.parent as? Ring{
            collision(withRing: ring)
        }
    }
    
    
}


