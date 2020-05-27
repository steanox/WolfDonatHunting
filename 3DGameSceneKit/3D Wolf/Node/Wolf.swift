//
//  Wolf.swift
//  3DGameSceneKit
//
//  Created by octavianus on 27/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import SceneKit

enum WolfState{
    case idle,running,walking
}

class Wolf: SCNNode{

    
    private var _wolfNodeWalking: SCNNode = SCNNode()
    private var _wolfNodeRunning: SCNNode = SCNNode()
    private var _wolfNodeIdle: SCNNode = SCNNode()
    private var _activeNode: SCNNode?
    
    
    override init() {
        super.init()
        loadWolfState()
        setWolf(state: .idle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func loadWolfState(){
        //Walking Scene
        guard
            let wolfSceneWalking = SCNScene(named: "ScnAsset.scnassets/wolf/Wolf_Walking.scn"),
            let wolfSceneRunning = SCNScene(named: "ScnAsset.scnassets/wolf/Wolf_Running.scn"),
            let wolfSceneIdle = SCNScene(named: "ScnAsset.scnassets/wolf/Wolf_Idle.scn")
        else {
            fatalError("Wolf Scene is missing")
        }
        _wolfNodeWalking.addChildNode(wolfSceneWalking.rootNode)
        _wolfNodeRunning.addChildNode(wolfSceneRunning.rootNode)
        _wolfNodeIdle.addChildNode(wolfSceneIdle.rootNode)
    }
    
    public func setWolf(state: WolfState){
        _activeNode?.removeFromParentNode()
        _activeNode = nil
        switch state {
        case .idle:
            _activeNode = _wolfNodeIdle
        case .walking:
            _activeNode = _wolfNodeWalking
        case .running:
            _activeNode = _wolfNodeRunning
        }
        addChildNode(_activeNode!)
    }
}
