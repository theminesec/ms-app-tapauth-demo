//
//  BottomNavView.swift
//  TapToAuth Demo
//
//  Created by Admin on 23/12/2024.
//

import SwiftUI

enum Tab: Hashable {
    case profile
    case notifications
}

struct ContentView: View {
    @State private var selectedTab: Tab = .profile
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(Tab.profile)
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }
                .tag(Tab.notifications)
        }
        .accentColor(.blue)
        .onAppear {
            NotificationCenter.default.addObserver(forName: .navigateToNotifications,
                                                   object: nil,
                                                   queue: .main) { _ in
                selectedTab = .notifications
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .navigateToNotifications, object: nil)
        }
        .onChange(of: appState.navigateToNotifications) { navigate in
            if navigate {
                selectedTab = .notifications
                appState.navigateToNotifications = false
                appState.pendingOrder = nil
            }
        }
    }
}
