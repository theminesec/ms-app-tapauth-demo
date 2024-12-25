//
//  BottomNavView.swift
//  TapToAuth Demo
//
//  Created by Admin on 23/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView(userName: "Mario Gamal")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }

            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }
        }
        .accentColor(.blue)
    }
}
