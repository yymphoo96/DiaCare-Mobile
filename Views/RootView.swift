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
                MainTabView(isAuthenticated: $isAuthenticated)
                
            } else {
                NavigationView {
                    LoginView(isAuthenticated: $isAuthenticated)
                }
            }
        }
    }
}
