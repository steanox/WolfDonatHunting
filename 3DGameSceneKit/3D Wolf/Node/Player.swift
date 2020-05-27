//
//  Player.swift
//  3DGameSceneKit
//
//  Created by octavianus on 25/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import SceneKit

class Player : SCNNode {
     public static let moveOffset: CGFloat = 10
    
    private let lookAtForwardPosition = SCNVector3Make(0.0, 0.0, 1.0)
    private let cameraFowardPosition = SCNVector3(x: 0, y: 1, z: -2)

    private var _lookAtNode: SCNNode?
    private var _cameraNode: SCNNode?
    private var _playerNode: SCNNode?
    private var _wolf: Wolf?

    override init() {
        super.init()
        
        loadWolf()
        loadCameraFollow()
        loadLight()
    }
    
    func loadWolf(){
        _wolf = Wolf()
        _wolf?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        _wolf?.physicsBody?.categoryBitMask = Game.Physics.Categories.player
        _wolf?.physicsBody!.contactTestBitMask = Game.Physics.Categories.ring
        addChildNode(_wolf!)
    }
    
    func changeWolfState(_ state: WolfState){
        _wolf?.setWolf(state: state)
    }
    
    func loadCameraFollow(){
        _lookAtNode = SCNNode()
        _lookAtNode!.position = lookAtForwardPosition
        addChildNode(_lookAtNode!)
        
        // Camera Node
        _cameraNode = SCNNode()
        _cameraNode!.camera = SCNCamera()
        _cameraNode!.position = cameraFowardPosition
        _cameraNode!.camera!.zNear = 0.1
        _cameraNode!.camera!.zFar = 200
        self.addChildNode(_cameraNode!)

        // Link them
        let constraint1 = SCNLookAtConstraint(target: _lookAtNode)
        constraint1.isGimbalLockEnabled = true
        _cameraNode!.constraints = [constraint1]
    }
    
    func loadLight(){
        // Create a spotlight at the player
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.directional
        spotLight.spotInnerAngle = 40.0
        spotLight.spotOuterAngle = 80.0
        spotLight.castsShadow = true
        spotLight.color = UIColor.white
        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        spotLightNode.position = SCNVector3(x: 1.0, y: 5.0, z: -2.0)
        self.addChildNode(spotLightNode)
//

        let constraint2 = SCNLookAtConstraint(target: self)
        constraint2.isGimbalLockEnabled = true
        spotLightNode.constraints = [constraint2]
//
        // Create additional omni light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.light!.color = UIColor.darkGray
        lightNode.position = SCNVector3(x: 0, y: 10.00, z: -2)
        self.addChildNode(lightNode)
    }
    
    public func move(_ direction: MovementDirection){
        let moveAction: SCNAction
        switch direction {
        case .right:
            moveAction = SCNAction.moveBy(x: 2, y: 0, z: 0, duration: 1)
        case .left:
            moveAction = SCNAction.moveBy(x: -2, y: 0, z: 0, duration: 1)
        }
        self.runAction(moveAction)
    }
    
//    private func toggleCamera() {
//        var position = _cameraNode!.position
//
//        if position.x < 0 {
//            position.x = 1.0
//        }
//        else {
//            position.x = -1.0
//        }
//
//        SCNTransaction.begin()
//        SCNTransaction.animationDuration = 1.0
//
//        _cameraNode?.position = position
//
//        SCNTransaction.commit()
//    }
    
    public func updateWolfPosition(joyStickData: AnalogJoystickData, velocityMultiplier: CGFloat){
        let xMovement = -joyStickData.velocity.x * velocityMultiplier
        let zMovement = (joyStickData.velocity.y * velocityMultiplier)
        
        self.position = SCNVector3(
            CGFloat(self.position.x) + xMovement,
            0,
            CGFloat(self.position.z) + zMovement)
        
        _wolf?.eulerAngles.y = Float(joyStickData.angular)
        
        _lookAtNode?.rotation = SCNVector4(
            Int((_lookAtNode?.position.y)! + Float(joyStickData.angular)),
            Int((_lookAtNode?.position.y)! + Float(joyStickData.angular)),
            Int((_lookAtNode?.position.y)! + Float(joyStickData.angular)),0)
        
        
    }
    
    
    required init(coder: NSCoder) {
        fatalError("Not yet implemented")
    }
}
