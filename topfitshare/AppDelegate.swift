//
//  AppDelegate.swift
//  topfitshare
//
//  Created by stepanekdavid on 3/31/17.
//  Copyright © 2017 Lovisa. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import UserNotifications
import Firebase
import GoogleSignIn
import CalendarKit

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var sessionID:String = ""
    var userEmail:String = ""
    var userName:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    var pointsNumber:Int = 0
    var curUserProfileImageUrl:String = ""
    var aboutMe:String = ""
    var level:String = ""
    var memberNum:String = ""
    
    var notifiCount:Int = 0
    
    var isShownWelcome:Bool?
    var isShownTipViewForWorkout:Bool?
    
    var workoutSelectedType:Int = 1
    
    var currentGym:String = ""
    var currentHelpforExercies:String = ""
    
    var notifi:String = ""
    
    var availWorkouts:[NSDictionary] = []
    var addOrEditWorkOutsArray:NSMutableDictionary?
    
    var arrUserInfo:[NSDictionary] = []
    
    var isLoginOrRegister:Bool = false
    var isFitLove:Bool?
    var isSelectedCar:Bool?
    var isRegister:Bool?
    var isLogin:Bool = false
    var isFaceBookLogin:Bool?
    
    var currentWeekday = 0
    
    var currentUserLat:Double = 0
    var currentUserLon:Double = 0
    var isLift = false
    
    let gcmMessageIDKey = "gcm.message_id"
    var strDeivceToken:String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController:mainViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
//        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
//        GIDSignIn.sharedInstance().delegate = self
        
        // Initialize sign-in
        let kClientID = "657228808711-irf22kvh9e42ehj5q2objbg14pls35gd.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().clientID = kClientID
        GIDSignIn.sharedInstance().delegate = self
        
        let navAppearance = UINavigationBar.appearance()
        let imgForBack:UIImage? = self.imageWithColor(color:  UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0)) //fitshare blue
        navAppearance.setBackgroundImage(imgForBack, for: UIBarMetrics.default)
        navAppearance.tintColor = UIColor.white
        navAppearance.barTintColor = UIColor(red: 39.0/255, green: 54.0/255, blue: 183.0/255, alpha: 1.0) //fitshare blue

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().remoteMessageDelegate = self as? MessagingDelegate
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
         return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    
    func imageWithColor(color:UIColor)->UIImage{
        let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(1.0), height: CGFloat(1.0))
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func saveLoginData(){
        UserDefaults.standard.set(sessionID, forKey: "sessionId")
        UserDefaults.standard.set(userEmail, forKey: "user_email")
        UserDefaults.standard.set(userFirstName, forKey: "first_name")
        UserDefaults.standard.set(userName, forKey: "user_name")
        UserDefaults.standard.set(userLastName, forKey: "last_name")
        UserDefaults.standard.set(0, forKey: "fitlove")
        UserDefaults.standard.set(curUserProfileImageUrl, forKey: "profileUrl")
        UserDefaults.standard.set(aboutMe, forKey: "aboutMe")
        UserDefaults.standard.set(currentGym, forKey: "currentGym")
        UserDefaults.standard.set(level, forKey: "level")
        UserDefaults.standard.set(isShownWelcome, forKey: "isShowingWelcome")
        UserDefaults.standard.set(notifiCount, forKey: "notifiCount")
        UserDefaults.standard.set(memberNum, forKey: "memberNum")
        UserDefaults.standard.set(isLift, forKey: "isLift")
    }
    
    func loadLoginData(){
        sessionID = UserDefaults.standard.string(forKey: "sessionId")!
        userEmail = UserDefaults.standard.string(forKey: "user_email")!
        userFirstName = UserDefaults.standard.string(forKey: "first_name")!
        userName = UserDefaults.standard.string(forKey: "user_name")!
        userLastName = UserDefaults.standard.string(forKey: "last_name")!
        pointsNumber = UserDefaults.standard.integer(forKey: "sharedNumber")
        curUserProfileImageUrl = UserDefaults.standard.string(forKey: "profileUrl")!
        isFitLove = UserDefaults.standard.bool(forKey: "fitlove")
        aboutMe = UserDefaults.standard.string(forKey: "aboutMe")!
        currentGym = UserDefaults.standard.string(forKey: "currentGym")!
        level = UserDefaults.standard.string(forKey: "level")!
        isShownWelcome = UserDefaults.standard.bool(forKey: "isShowingWelcome")
        notifiCount = UserDefaults.standard.integer(forKey: "notifiCount")
        memberNum = UserDefaults.standard.string(forKey: "memberNum")!
        isLift = UserDefaults.standard.bool(forKey: "isLift")

    }
    
    func deleteLoginData(){
        isLoginOrRegister = false
        isFaceBookLogin = false
        UserDefaults.standard.removeObject(forKey: "sessionId")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "first_name")
        UserDefaults.standard.removeObject(forKey: "user_name")
        UserDefaults.standard.removeObject(forKey: "last_name")
        UserDefaults.standard.removeObject(forKey: "sharedNumber")
        UserDefaults.standard.removeObject(forKey: "fitlove")
        UserDefaults.standard.removeObject(forKey: "profileUrl")
        UserDefaults.standard.removeObject(forKey: "aboutMe")
        UserDefaults.standard.removeObject(forKey: "currentGym")
        UserDefaults.standard.removeObject(forKey: "level")
        UserDefaults.standard.removeObject(forKey: "isShowingWelcome")
        UserDefaults.standard.removeObject(forKey: "isShowingTipViewForWorkout")
        UserDefaults.standard.removeObject(forKey: "notifiCount")
        UserDefaults.standard.removeObject(forKey: "memberNum")
        UserDefaults.standard.removeObject(forKey: "isLift")
        sessionID = ""
        userEmail = ""
        userFirstName = ""
        userName = ""
        userLastName = ""
        pointsNumber = 0
        curUserProfileImageUrl = ""
        isFitLove = false
        aboutMe = ""
        currentGym = ""
        level = ""
        isShownWelcome = false
        isShownTipViewForWorkout = false
        notifiCount = 0
        memberNum = ""
        isLift = false
    }
    
    func goToMainContact(){
        isLoginOrRegister = true
        let vc = MainViewController()
        let naviCon = UINavigationController.init(rootViewController: vc)
        self.window?.rootViewController = naviCon;
    }
    
    func goToMyWorkouts(){
        let vc = MyWorkoutsViewController()
        let naviCon = UINavigationController.init(rootViewController: vc)
        self.window?.rootViewController = naviCon;
    }
    
    func goToSplash(){
        let vc = LoginViewController()
        let naviCon = UINavigationController.init(rootViewController: vc)
        self.window?.rootViewController = naviCon;
    }
    
    func goToGYMSelected(){
    
    }
    
    func gotoAddWorkoutsView(){
    
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func jsonToString(json: AnyObject) -> String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString! // <-- here is ur string
            
        } catch _ {
            return ""
        }
    
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
    }

//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let invite = Invites.handle(url, sourceApplication:sourceApplication, annotation:annotation) as? ReceivedInvite {
            let matchType =
                (invite.matchType == .weak) ? "Weak" : "Strong"
            print("Invite received from: \(sourceApplication ?? "") Deeplink: \(invite.deepLink)," +
                "Id: \(invite.inviteId), Type: \(matchType)")
            return true
        }
        
        let urlString = url.absoluteString
        if (urlString as NSString).range(of: "fb622225134635250").location != NSNotFound{
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if error != nil {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        _ = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //FIRMessaging.messaging().disconnect()
        //print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
       
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "topfitshare")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().disconnect()
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error ?? "" as! Error)")
            } else {
                print("Connected to FCM.")
                self.strDeivceToken = InstanceID.instanceID().token()!
                
                if self.userName != "" {
                    let rootR = Database.database().reference(fromURL: "https://atc-fitness.firebaseio.com/user info")
                    var updateToken = [String: Any]()
                    updateToken["token"] = self.strDeivceToken
                    rootR.child(self.userName).updateChildValues(updateToken)
                }
                
            }
        }
    }
    // [END connect_to_fcm]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")

            InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)

            InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)

    }


    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
        // Receive data message on iOS 10 devices while app is in the foreground.
        func application(received remoteMessage: MessagingRemoteMessage) {
            print(remoteMessage.appData)
        }

}
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
}
// [END ios_10_message_handling]

