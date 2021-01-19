//
//  AppDelegate.swift
//  EPRINE
//
//  Created by Mobile on 15/07/20.
//  Copyright © 2020 Mobile. All rights reserved.
//Your App ID: 8b76ca5c-b7f1-469b-89ab-a7ba54809a67

import UIKit
import OneSignal
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {
    
    var window: UIWindow?
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")
        
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            print("Current playerId \(playerId)")
            UserStore.shared.deviceToken = playerId
            let infoDict : [String : String] = ["deviceId": playerId]
            print("infoDict",infoDict)
            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: infoDict)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(3)
        OneSignal.add(self as OSSubscriptionObserver)
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "9ede2442-fa35-4365-a93c-7264f6f6ec11",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        DispatchQueue.main.async {
            if UserStore.shared.boolLogout == true {
                self.setLogin()
            } else {
                if UserStore.shared.boolBioMetric {
                    self.setSplash()
                } else {
                    self.setHome()
                }
            }
        }
        IQKeyboardManager.shared.enable = true
        return true
    }
    
    
     func setLogin() {
         let story = UIStoryboard(name: "Main", bundle:nil)
         let vc = story.instantiateViewController(withIdentifier: "NavLogin")
         UIApplication.shared.windows.first?.rootViewController = vc
         UIApplication.shared.windows.first?.makeKeyAndVisible()
     }
     
     func setSplash() {
         let story = UIStoryboard(name: "Main", bundle:nil)
         let vc = story.instantiateViewController(withIdentifier: "NavSplash")
         UIApplication.shared.windows.first?.rootViewController = vc
         UIApplication.shared.windows.first?.makeKeyAndVisible()
     }
     
     func setHome() {
         let story = UIStoryboard(name: "Main", bundle:nil)
         let vc = story.instantiateViewController(withIdentifier: "NavHome")
         UIApplication.shared.windows.first?.rootViewController = vc
         UIApplication.shared.windows.first?.makeKeyAndVisible()
     }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

