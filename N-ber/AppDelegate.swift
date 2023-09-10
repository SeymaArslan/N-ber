//
//  AppDelegate.swift
//  N-ber
//
//  Created by Seyma on 15.08.2023.
//

import UIKit
import FirebaseCore
import FirebaseMessaging  // ++++

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var firstRun: Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self  //+++++
        requestPushNotificationPermissin()   // ++++
        
        firstRunCheck()
        
        application.registerForRemoteNotifications() // ++++  this will kick start the registration for remote notifications and pop up these remote notifications request, which will ask our user to register for remote notifications
        
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
    
    
    //MARK: - Remote Notifications ++++
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications", error.localizedDescription)
    }
    
    private func requestPushNotificationPermissin() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
            
        }
    }
    
    private func updateUserPushId(newPushId: String) { // what is function is going to be user for once we launch our application, Firebase will our application will ask to register for push notifications
        
        if var user = User.currentUser {
            user.pushId = newPushId
            saveUserLocally(user)
            FirebaseUserListener.shared.updateUserInFirebase(user)
        }
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

// +++++
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}

// +++++
extension AppDelegate: MessagingDelegate { // this is our cloud firebase.. from pods firebaseMessaging
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print(" user push topken is ", fcmToken)
        updateUserPushId(newPushId: fcmToken!)
    }
}
