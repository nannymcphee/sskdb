//
//  AppDelegate.swift
//  shealthcare
//
//  Created by SangWooKim on 08/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import MKProgress
import UserNotifications
import os.log

extension Notification.Name {
    static let drug = Notification.Name("observerPushDrug")
    static let drugComplate = Notification.Name("observerPushDrugComplate")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Neat.active()
        
        let group = DispatchGroup()
        group.enter()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            debugPrint("requests.count = \(requests.count)")
            for request in requests {
                debugPrint("request.identifier = \(request.identifier)")
            }
            group.leave()
        })
        _ = group.wait(timeout: .distantFuture)
        
        
        sleep(2)
        
        // 쿠키 모든 사이트에서 허용.
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
//        MKProgress.config.hudType = .radial
        MKProgress.config.width = 64.0
        MKProgress.config.height = 64.0
        MKProgress.config.hudColor = .clear
//        MKProgress.config.backgroundColor = UIColor(white: 0, alpha: 0.55)
//        MKProgress.config.cornerRadius = 16.0
//        MKProgress.config.fadeInAnimationDuration = 0.2
//        MKProgress.config.fadeOutAnimationDuration = 0.25
//        MKProgress.config.hudYOffset = 15
//        
        MKProgress.config.circleRadius = 20.0
        MKProgress.config.circleBorderWidth = 2.0
        MKProgress.config.circleBorderColor = .red
//        MKProgress.config.circleAnimationDuration = 0.9
//        MKProgress.config.circleArcPercentage = 0.85
//        
//        MKProgress.config.activityIndicatorStyle = .whiteLarge
//        MKProgress.config.activityIndicatorColor = .black
//        MKProgress.config.preferredStatusBarStyle = .lightContent
//        MKProgress.config.prefersStatusBarHidden = false
        
        // apns 등록
        registeredForRemoteNotifications(application: application)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    
    // MARK: - Push
    // MARK: >> apns 등록
    func registeredForRemoteNotifications(application: UIApplication) {
        //
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            //카테고리를 이용한 NotificationAction
            let acceptAction = UNNotificationAction(
                identifier: "com.kissoft.yes",
                title: "확인",
                options: [.foreground]
            )
            let declineAction = UNNotificationAction(
                identifier: "com.kissoft.no",
                title: "닫기",
                options: [.destructive]
            )
            let category = UNNotificationCategory(
                identifier: "fp",
                actions: [acceptAction, declineAction],
                intentIdentifiers: [],
                options:.customDismissAction
            )
            center.setNotificationCategories([category])
            
            center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted, error) in
                
                if (granted == true){
                    DispatchQueue.main.async(execute: {
                        application.registerForRemoteNotifications()
                    })
                } else {
                    print("User Notification permission denied")
                    if error != nil {
                        print("error : \(error.debugDescription)")
                    }
                }
                
            })
            
        } else {
            
            let types = UIUserNotificationType([.alert, .sound, .badge])
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            
            application.registerForRemoteNotifications()
        }
        
    }
    
    // MARK: >> delegate
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
        
        var tokenStr: String = ""
        for i in 0..<deviceToken.count {
            tokenStr += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        debugPrint(tokenStr)
        Global.token = tokenStr
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("APNs registration failed: \(error)")
    }
    
    //MARK: >> iOS10
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound,.badge])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 푸시를 누르고 들어왔을 경우.
        let userInfo = response.notification.request.content.userInfo
        if let type = userInfo["type"] as? String,
            let datetime = userInfo["datetime"] as? String {
            
            if type.hasPrefix("DRUGTIME") {
                DispatchQueue.global().async {
                    while true {
                        if Global.loadingSuccess {
                            // 10분 후 알람은 제거 한다.
                            let next = response.notification.request.identifier + "_NEXT"
                            let center = UNUserNotificationCenter.current()
                            center.removePendingNotificationRequests(withIdentifiers: [next])
                            debugPrint("next = \(next)")
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .drug, object: nil, userInfo: userInfo)
                            }
                            return
                        }
                        sleep(1)
                    }
                }
            }
        }
        
        completionHandler()
    }
}

