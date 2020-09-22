//
//  AppDelegate.swift
//  SchoolLift
//
//  Created by Adrian Rivacoba on 4/12/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    var notificationCenter: UNUserNotificationCenter?



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        FirebaseApp.configure()

        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        
        // get the singleton object
        self.notificationCenter = UNUserNotificationCenter.current()
        
        // register as it's delegate
        notificationCenter?.delegate = self
        
        // define what do you need permission to use
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        // request permission
        notificationCenter?.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }

        return true
    }

//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        if let vc = window?.rootViewController as? RequestVC {
//            vc.waitingForRide()
//            completionHandler(.newData)
//        }
//    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Background entered")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        /* chart:
         0 = the user is neither a driver or rider that is active
         1 = the user is the driver before pick up and active
         2 = the user is the driver after pick up and before drop off and active
         3 = the user is the driver after drop off and active (not used yet)
         4 = the user is the rider and active
         
         
         **active means within 30 minutes of ride or actually during ride
        */
        
        if SingleAppDelegate.sharedInstance.vcadcontroller == 1 {
            
            let viewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "DriverPickUpViewController")
            self.window?.rootViewController = viewController
            
        } else if SingleAppDelegate.sharedInstance.vcadcontroller == 2 {
            
            let viewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "DropOffViewController")
            self.window?.rootViewController = viewController
            
        } else if SingleAppDelegate.sharedInstance.vcadcontroller == 3 {
            
        } else if SingleAppDelegate.sharedInstance.vcadcontroller == 4 {
            
            let viewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "PickUpViewController")
            self.window?.rootViewController = viewController
            
        } else if SingleAppDelegate.sharedInstance.vcadcontroller == 0 {
            
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: CLLocationManagerDelegate {

    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
            self.handleEvent(forRegion: region)

        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        
        //
        if SingleAppDelegate.sharedInstance.vcadcontroller == 4 {
        
            // customize your notification content
            let content = UNMutableNotificationContent()
            content.title = "Your Driver is close!"
            content.body = "Look out for your driver!"
            content.sound = UNNotificationSound.default
        
            // when the notification will be triggered
            let timeInSeconds: TimeInterval = (5) //5 seconds
            
            // the actual trigger object
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                        repeats: false)
        
            // notification unique identifier, for this example, same as the region to avoid duplicate notifications
            let identifier = region.identifier
        
            // the notification request object
            let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
            // trying to add the notification request to notification center
            notificationCenter?.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("Error adding notification with identifier: \(identifier)")
                }
            })
        } else {
            // customize your notification content
            let content = UNMutableNotificationContent()
            content.title = "Pick up passenger"
            content.body = "You are almost at location"
            content.sound = UNNotificationSound.default
            
            // when the notification will be triggered
            let timeInSeconds: TimeInterval = (5) //5 seconds
            
            // the actual trigger object
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                            repeats: false)
            
            // notification unique identifier, for this example, same as the region to avoid duplicate notifications
            let identifier = region.identifier
            
            // the notification request object
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content,
                                                trigger: trigger)
            
            // trying to add the notification request to notification center
            notificationCenter?.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("Error adding notification with identifier: \(identifier)")
                }
            })
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // get the notification identifier to respond accordingly
    
        // Access the storyboard and fetch an instance of the view controller
        if SingleAppDelegate.sharedInstance.vcadcontroller == 4 {
            let viewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "PickUpViewController")
            self.window?.rootViewController = viewController

        } else {
        
            let viewController = self.window!.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "DriverPickUpViewController")
            self.window?.rootViewController = viewController
        }
        
        completionHandler()

    }
}

