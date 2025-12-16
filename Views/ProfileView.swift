////
////  ProfileView.swift
////  ReceiveData
////
////  Created by Yin Yin May Phoo on 01/10/2025.
////
//import SwiftUI
//
//struct ProfileView: View {
//    @State private var user: User?
//    @State private var isEditingName = false
//    @State private var newName = ""
//    @State private var isLoading = false
//    @Binding var isAuthenticated: Bool
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if let user = user {
//                VStack(spacing: 10) {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.blue)
//                    
//                    if isEditingName {
//                        HStack {
//                            TextField("Name", text: $newName)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                            
//                            Button("Save") {
//                                updateProfile()
//                            }
//                            .buttonStyle(.borderedProminent)
//                            
//                            Button("Cancel") {
//                                isEditingName = false
//                                newName = user.name
//                            }
//                            .buttonStyle(.bordered)
//                        }
//                    } else {
//                        HStack {
//                            Text(user.name)
//                                .font(.title2)
//                                .fontWeight(.bold)
//                            
//                            Button(action: {
//                                isEditingName = true
//                                newName = user.name
//                            }) {
//                                Image(systemName: "pencil")
//                            }
//                        }
//                    }
//                    
//                    Text(user.email)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//                
//                Button("Logout") {
//                    AuthService.shared.logout()
//                    isAuthenticated = false
//                }
//                .buttonStyle(.bordered)
//                .foregroundColor(.red)
//            } else if isLoading {
//                ProgressView()
//            } else {
//                Text("Failed to load profile")
//            }
//        }
//        .task {
//            await loadProfile()
//        }
//    }
//    
//    private func loadProfile() async {
//        isLoading = true
//        do {
//            let fetchedUser = try await AuthService.shared.getProfile()
//            await MainActor.run {
//                self.user = fetchedUser
//                self.newName = fetchedUser.name
//                isLoading = false
//            }
//        } catch {
//            await MainActor.run {
//                isLoading = false
//            }
//        }
//    }
//    
//    private func updateProfile() {
//        Task {
//            do {
//                let updatedUser = try await AuthService.shared.updateProfile(name: newName)
//                await MainActor.run {
//                    self.user = updatedUser
//                    isEditingName = false
//                }
//            } catch {
//                print("Failed to update profile: \(error)")
//            }
//        }
//    }
//}
