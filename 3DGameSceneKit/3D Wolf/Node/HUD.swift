//
//  HUD.swift
//  3DGameSceneKit
//
//  Created by octavianus on 27/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import Foundation
import SpriteKit

class HUD{
    private var _scene: SKScene!
    private let _points = SKLabelNode(text: "0 Rings")
    var joyStick: AnalogJoystick!
    
    var scene: SKScene {
        return _scene
    }
    
    var points: Int{
        get{
            return 0
        }
        set{
            _points.text = "\(newValue) Rings"
        }
    }
    
    init(size: CGSize) {
        _scene = SKScene(size: size)
        
        joyStick = AnalogJoystick(diameter: size.width / 2,colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick:#imageLiteral(resourceName: "jStick")))
        joyStick.position = CGPoint(x: size.width / 2, y: size.width / 2)
        _scene.addChild(joyStick)
        
        _points.position = CGPoint(x: size.width/2, y: size.height - 100)
        _points.horizontalAlignmentMode = .center
        _points.fontName = "MarkerFelt-Wide"
        _points.fontSize = 30
        _points.fontColor = UIColor.white
        
        _scene.addChild(_points)
        

    }
}
