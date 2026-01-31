import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate { // เพิ่ม MessagingDelegate

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 1. ลงทะเบียน Plugin ของ Flutter
        GeneratedPluginRegistrant.register(with: self)

        // 2. ตั้งค่าการแจ้งเตือน (Delegates)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        // เชื่อมต่อ Messaging Delegate กับ AppDelegate นี้
        Messaging.messaging().delegate = self

        // 3. ขออนุญาตแจ้งเตือนจากผู้ใช้
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("✅ Notification permission granted")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("❌ Notification permission denied: \(error.localizedDescription)")
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Firebase Messaging Token (ห้ามใส่ override)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let token = fcmToken ?? ""
        print("📱 FCM Token: \(token)")
        
        // เก็บ Token ไว้ใน UserDefaults
        UserDefaults.standard.set(token, forKey: "fcm_token")
        
        let dataDict: [String: String] = ["token": token]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }

    // MARK: - Push Notification Handling
    
    // รับแจ้งเตือนเมื่อแอปเปิดอยู่ (Foreground)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("📩 Foreground Notification: \(userInfo)")

        // แสดง Banner และ Sound แม้แอปจะเปิดอยู่
        completionHandler([[.banner, .badge, .sound]])
    }

    // เมื่อผู้ใช้ "คลิก" ที่การแจ้งเตือน
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("👆 Notification Clicked: \(userInfo)")
        
        completionHandler()
    }

    // MARK: - APNs Registration
    
    override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // ส่ง Device Token ให้ Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        print("🔗 APNs token registered")
        
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("⚠️ Failed to register for remote notifications: \(error.localizedDescription)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}
