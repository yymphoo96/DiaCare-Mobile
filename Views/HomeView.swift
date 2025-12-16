//
//  HomeView.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 28/11/2025.
//
import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @State private var dailyChallengeProgress = 5
    @State private var totalChallenges = 8
    @Binding var currentUser: User?  // ADD THIS
    @State private var showHealthProfileSheet = false  // ADD THIS
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if let user = currentUser, user.healthProfile == nil || user.healthProfile?.isComplete == false {
                                HealthProfileBanner(showSheet: $showHealthProfileSheet)
                                    .padding(.horizontal)
                            }
                            Text("Hello, \(currentUser?.name.split(separator: " ").first.map(String.init) ?? "User")!")
                                                           .font(.subheadline)
                                                           .foregroundColor(.gray)
                            
                            Text("Welcome back")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        // Chatbot Button
                        Button(action: {
                            // Open chatbot
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "message.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Profile Picture
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.7), Color.pink.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Daily Challenge Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Daily challenge")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(dailyChallengeProgress)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.purple)
                                    
                                    Text("of \(totalChallenges) completed")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 70, height: 70)
                        }
                        
                        // Progress Bars
                        HStack(spacing: 4) {
                            ForEach(0..<totalChallenges, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(index < dailyChallengeProgress ? Color.purple : Color.purple.opacity(0.2))
                                    .frame(height: 6)
                            }
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    // Diabetes Risk Check Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Diabetes Risk Check")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("AI-powered health prediction")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("🩺")
                                .font(.system(size: 32))
                        }
                        
                        Button(action: {
                            // Navigate to diabetes prediction
                        }) {
                            Text("Check Your Risk")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        
                        Text("Based on your health metrics & lifestyle")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.05), Color.orange.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .padding(.horizontal)
                    
                    // Today's Activities Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Activities")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Activity Stats
                        HStack(spacing: 12) {
                            ActivityStatCard(icon: "figure.walk",value: "8.5k", label: "Steps", color: .green)
                            ActivityStatCard(icon: "figure.cal",value: "245", label: "Calories", color: .orange)
                            ActivityStatCard(icon: "figure.walk",value: "65m", label: "Active", color: .blue)
                        }
                        .padding(.horizontal)
                        
                        // Activity List
                        VStack(spacing: 12) {
                            ActivityRow(
                                emoji: "🧘‍♀️",
                                title: "Morning Yoga",
                                duration: "30 min",
                                calories: "85 calories",
                                isCompleted: true,
                                backgroundColor: Color.purple.opacity(0.1)
                            )
                            
                            ActivityRow(
                                emoji: "🏃‍♀️",
                                title: "Evening Walk",
                                duration: "45 min",
                                calories: "160 calories",
                                isCompleted: true,
                                backgroundColor: Color.pink.opacity(0.1)
                            )
                            
                            ActivityRow(
                                emoji: "🧘",
                                title: "Meditation",
                                duration: "15 min",
                                calories: "Pending",
                                isCompleted: false,
                                backgroundColor: Color.blue.opacity(0.1)
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showHealthProfileSheet) {  // ADD THIS
                            HealthProfileFormView(user: $currentUser, isPresented: $showHealthProfileSheet)
                        }
        }
    }
}
