//
//  File.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 28/11/2025.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    @Binding var isAuthenticated: Bool
    @State private var currentUser: User? // ← ADD THIS
    @State private var isLoadingUser = true // ← ADD THIS
    
    var body: some View {
        Group {
            if isLoadingUser {
                ProgressView("Loading...")
            } else {
                TabView(selection: $selectedTab) {
                    // ← CHANGE: Pass currentUser to HomeView
                    HomeView(currentUser: $currentUser)
                        .tabItem {
                            Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    ActivityView()
                        .tabItem {
                            Image(systemName: selectedTab == 1 ? "figure.run" : "figure.walk")
                            Text("Activity")
                        }
                        .tag(1)
                    
                    // ← CHANGE: Pass currentUser to ProfileView
                    ProfileView(isAuthenticated: $isAuthenticated, currentUser: $currentUser)
                        .tabItem {
                            Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                            Text("Profile")
                        }
                        .tag(2)
                }
                .accentColor(.purple)
            }
        }
        .onAppear {
            loadUser() // ← ADD THIS
        }
    }
    
    // ← ADD THIS ENTIRE FUNCTION
    private func loadUser() {
        isLoadingUser = true
        
        // Try loading from cache first
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let cachedUser = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = cachedUser
            isLoadingUser = false
        }
        
        // Then fetch fresh data from API
        Task {
            do {
                let fetchedUser = try await AuthService.shared.getProfile()
                await MainActor.run {
                    currentUser = fetchedUser
                    isLoadingUser = false
                    
                    // Save to cache
                    if let encoded = try? JSONEncoder().encode(fetchedUser) {
                        UserDefaults.standard.set(encoded, forKey: "currentUser")
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingUser = false
                }
                print("Failed to fetch user profile: \(error)")
            }
        }
    }
}


// MARK: - Profile View
struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    @Binding var currentUser: User? // ← CHANGED: Now uses binding from parent
    @State private var isEditingName = false
    @State private var newName = ""
    @State private var showHealthProfileSheet = false // ← NEW
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = currentUser { // ← CHANGED: Uses currentUser instead of self.user
                        // Profile Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(0.7), Color.pink.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                            
                            // Name Section with Edit
                            if isEditingName {
                                VStack(spacing: 12) {
                                    TextField("Name", text: $newName)
                                        .textFieldStyle(.roundedBorder)
                                        .padding(.horizontal, 40)
                                    
                                    HStack(spacing: 12) {
                                        Button("Save") {
                                            updateProfile()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.purple)
                                        
                                        Button("Cancel") {
                                            isEditingName = false
                                            newName = user.name
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.gray)
                                    }
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Button(action: {
                                        isEditingName = true
                                        newName = user.name
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .padding(8)
                                            .background(Color.gray.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                
                                Text(user.email)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats Grid
                        HStack(spacing: 12) {
                            StatCard(icon: "figure.walk",value: "28", label: "Days streak", color: .green)
                            StatCard(icon: "figure.walk",value: "156", label: "Workouts", color: .blue)
                            StatCard(icon: "figure.walk",value: "2.4k", label: "Cal burned", color: .orange)
                        }
                        .padding(.horizontal)
                        
                        // Menu Items
                        VStack(spacing: 8) {
                            Button(action: { showHealthProfileSheet = true }) {
                                MenuItemRow(title: "Health Profile", icon: "heart.text.square.fill")
                            }
                            MenuItemRow(title: "Personal profile", icon: "person.fill")
                            MenuItemRow(title: "Statistics", icon: "chart.bar.fill")
                            MenuItemRow(title: "Settings", icon: "gearshape.fill")
                            MenuItemRow(title: "Your plan", icon: "calendar")
                            MenuItemRow(title: "Preferences", icon: "slider.horizontal.3")
                            MenuItemRow(title: "Help center", icon: "questionmark.circle.fill")
                        }
                        .padding(.horizontal)
                        
                        // Logout Button
                        Button(action: {
                            AuthService.shared.logout()
                            isAuthenticated = false
                            UserDefaults.standard.removeObject(forKey: "currentUser")
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red, lineWidth: 2)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                )
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                    } else {
                        ProgressView("Loading profile...")
                            .scaleEffect(1.5)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showHealthProfileSheet) {
                HealthProfileFormView(user: $currentUser, isPresented: $showHealthProfileSheet)
            }
        }
    }
    
    // ← REMOVE the old loadProfile() function completely
    // ← ADD this new updateProfile() function
    private func updateProfile() {
        Task {
            do {
                let updatedUser = try await AuthService.shared.updateProfile(name: newName)
                await MainActor.run {
                    currentUser = updatedUser
                    isEditingName = false
                    
                    if let encoded = try? JSONEncoder().encode(updatedUser) {
                        UserDefaults.standard.set(encoded, forKey: "currentUser")
                    }
                }
            } catch {
                print("Failed to update profile: \(error)")
            }
        }
    }
}


struct ActivityRow: View {
    let emoji: String
    let title: String
    let duration: String
    let calories: String
    let isCompleted: Bool
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))
                .frame(width: 48, height: 48)
                .background(backgroundColor)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text("\(duration) • \(calories)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .opacity(isCompleted ? 1.0 : 0.6)
    }
}



struct MenuItemRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.purple)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct RecentActivityRow: View {
    let name: String
    let time: String
    let calories: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text("\(time) • \(calories)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    MainTabView(isAuthenticated: .constant(true))
}
