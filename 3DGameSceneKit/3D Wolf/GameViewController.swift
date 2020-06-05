//
//  GameViewController.swift
//  3DGameSceneKit
//
//  Created by octavianus on 25/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import SceneKit
import UIKit

class GameViewController: UIViewController {
    var sceneView: SCNView?
    var level1Scene = Level1Scene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = SCNView()
        level1Scene.createLevel()
        sceneView?.scene = level1Scene
        sceneView?.allowsCameraControl = false
        sceneView?.backgroundColor = UIColor.black
        sceneView?.showsStatistics = true
        sceneView?.debugOptions = .showWireframe
        sceneView?.delegate = self
        
        view = sceneView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let hud = HUD(size: view.bounds.size)
        level1Scene.hud = hud
        level1Scene.hud?.joyStick.trackingHandler = level1Scene.updatePlayerPosition
        level1Scene.hud?.joyStick.stopHandler = { [weak self] in
            self?.level1Scene.updatePlayerState(.idle)
        }
        
        level1Scene.hud?.joyStick.beginHandler = { [weak self] in
            self?.level1Scene.updatePlayerState(.running)
        }
        sceneView?.overlaySKScene = hud.scene
    }

}

extension GameViewController: SCNSceneRendererDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        level1Scene.update(atTime: time)
        renderer.loops = true
    }
}
