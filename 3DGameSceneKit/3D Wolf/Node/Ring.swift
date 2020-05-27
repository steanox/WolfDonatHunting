//
//  Ring.swift
//  3DGameSceneKit
//
//  Created by octavianus on 27/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class Ring: SCNNode{
    
    override init() {
        super.init()
        //Ring
        let ringMaterial = SCNMaterial()
        ringMaterial.diffuse.contents = UIColor.red
        ringMaterial.diffuse.wrapS = .repeat
        ringMaterial.diffuse.wrapT = .repeat
        ringMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(3, 1, 1)
        
        let ring = SCNTorus(ringRadius: 0.3, pipeRadius: 0.1)
        ring.materials = [ringMaterial]
        
        let ringNode = SCNNode(geometry: ring)
        ringNode.eulerAngles = SCNVector3(GLKMathDegreesToRadians(90),0,0)
        
        addChildNode(ringNode)
        
        let ringAction = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(GLKMathDegreesToRadians(360)), duration: 3)
        ringNode.runAction(SCNAction.repeatForever(ringAction))
        
        // Contact box
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)

        let box = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
        box.materials = [boxMaterial]
        let contactBox = SCNNode(geometry: box)
        contactBox.name = "ring"
        contactBox.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        contactBox.physicsBody?.categoryBitMask = Game.Physics.Categories.ring
        self.addChildNode(contactBox)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
