//
//  TapToAuth_DemoApp.swift
//  TapToAuth Demo
//
//  Created by Admin on 18/12/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission request failed: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            handleNotification(notification)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo)
        completionHandler()
    }
    
    private func handleNotification(_ userInfo: [AnyHashable: Any]) {
        print("User tapped notification: \(userInfo)")
        NotificationCenter.default.post(name: .navigateToNotifications, object: nil)
    }
}

@main
struct TapToAuth_DemoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @State private var showPendingOrderAlert = false
    @State private var pendingOrder: Order? = nil

    var body: some Scene {
        WindowGroup {
            if retrieveUser() != nil {
                ContentView()
                    .environmentObject(appState)
                    .onAppear {
                        observePendingOrder()
                    }
                    .alert(isPresented: $showPendingOrderAlert) {
                        pendingOrderAlert()
                    }
            }
            else {
                LoginView()
                    .environmentObject(appState)
                    .onDisappear {
                        observePendingOrder()
                    }
                    .alert(isPresented: $showPendingOrderAlert) {
                        pendingOrderAlert()
                    }
            }
        }
    }
    
    private func observePendingOrder() {
        guard let user = retrieveUser() else { return }
        ActionObserver().observeCardActions(cardNumber: user.cardNo) { pendingOrder in
            DispatchQueue.main.async {
                self.pendingOrder = pendingOrder
                self.showPendingOrderAlert = true
            }
        }
    }
    
    private func pendingOrderAlert() -> Alert {
        Alert(
            title: Text("Verify Your Purchase"),
            message: Text("A pending order requires your attention. Do you want to view it?"),
            primaryButton: .default(Text("OK")) {
                if let pendingOrder = pendingOrder {
                    handlePendingOrder(pendingOrder)
                }
            },
            secondaryButton: .cancel {
                pendingOrder = nil
            }
        )
    }
    
    private func handlePendingOrder(_ order: Order) {
        DispatchQueue.main.async {
            appState.navigateToNotifications = true
            appState.pendingOrder = order
        }
    }
}


extension Notification.Name {
    static let navigateToNotifications = Notification.Name("NavigateToNotifications")
}


class AppState: ObservableObject {
    @Published var navigateToNotifications = false // Trigger navigation
    @Published var pendingOrder: Order? = nil // Store pending order
}
