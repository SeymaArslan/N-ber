//
//  AppDelegate.swift
//  N-ber
//
//  Created by Seyma on 15.08.2023.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var firstRun: Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        firstRunCheck()
        
        LocationManager.shared.startUpdating() // so that our locationManager will start working and also the most important think that this variable (currentLocation) will have value with our latest location so that we can use it in order to send our location messages
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    //MARK: - First Run
    private func firstRunCheck() {
        firstRun = userDefaults.bool(forKey: kFirstRun)
        if !firstRun! {
        //    let status = Status.array.map { $0.rawValue }   before added Status: CaseIterable
            let status = Status.allCases.map { $0.rawValue }  // *
            userDefaults.set(status, forKey: kStatus)
            userDefaults.set(true, forKey: kFirstRun)
            
            userDefaults.synchronize()
        }
        
    }

}

