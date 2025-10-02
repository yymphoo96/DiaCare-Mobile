//
//  RootView.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 01/10/2025.
//

import SwiftUI
struct RootView: View {
    @State private var isAuthenticated = AuthService.shared.isAuthenticated()
    
    var body: some View {
        Group {
            if isAuthenticated {
                TabView {
                    ProfileView(isAuthenticated: $isAuthenticated)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                    
                    // Your existing ManageActivities view
                    Text("Manage Activities")
                        .tabItem {
                            Label("Activities", systemImage: "list.bullet")
                        }
                }
            } else {
                NavigationView {
                    LoginView(isAuthenticated: $isAuthenticated)
                }
            }
        }
    }
}
