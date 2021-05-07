//
//  SceneDelegate.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var playlistsSaved = false;


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if (!playlistsSaved) {
            GameDictionary.sharedPlaylists.savePlaylists();
            playlistsSaved = true;
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        playlistsSaved = false;
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        if (!playlistsSaved) {
            GameDictionary.sharedPlaylists.savePlaylists();
            playlistsSaved = true;
        }
    }


}

