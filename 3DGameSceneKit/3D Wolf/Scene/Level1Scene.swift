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


class Level1Scene: SCNScene{
    private let velocityMultiplier: CGFloat = 0.0016
    private let levelWidth = 320
    private let levelLength = 640
    private let numberOfRings = 100
    
    private var terrain: RBTerrain!
    private var _player: Player?
    
    
    var hud: HUD?
    
    var touchedRing: Int = 0
    
    func createLevel(){
        addTerrain()
        addPlayer()
        spawnRings()
        self.physicsWorld.contactDelegate = self
    }
    
    func update(atTime: TimeInterval){
        
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
        
//        let moveAction = SCNAction.moveBy(x: 0, y: 0, z: 200, duration: 50)
//        _player!.runAction(moveAction)
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
}

extension Level1Scene: SCNPhysicsContactDelegate{
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if let ring = contact.nodeB.parent as? Ring{
            collision(withRing: ring)
        }
    }
    
    
}


