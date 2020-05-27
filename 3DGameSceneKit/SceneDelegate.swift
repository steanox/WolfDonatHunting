//
//  SceneDelegate.swift
//  3DGameSceneKit
//
//  Created by octavianus on 23/05/20.
//  Copyright © 2020 com.octavianus. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Done Forget to remove the main in the info.plist
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = GameViewController()
        window?.makeKeyAndVisible()
        
    }


}

