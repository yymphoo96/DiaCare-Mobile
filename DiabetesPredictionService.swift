//
//  DiabetesPredictionService.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 26/12/2025.
//

import Foundation
import SwiftUI

// MARK: - Response Model

struct DiabetesPredictionResponse: Codable {
    let prediction: String
    let probability: Double
    let riskLevel: String
    let riskScore: Int
    let riskFactors: [String]
    let recommendations: [String]
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case prediction, probability
        case riskLevel = "risk_level"
        case riskScore = "risk_score"
        case riskFactors = "risk_factors"
        case recommendations, timestamp
    }
}

// MARK: - Prediction Service

class DiabetesPredictionService: ObservableObject {
    @Published var isLoading = false
    @Published var prediction: DiabetesPredictionResponse?
    @Published var errorMessage: String?
    
    private let baseURL = "http://172.20.10.8:8000/api" // Update with your server IP
    
    func predictDiabetesRisk(healthProfile: HealthProfile, physicalActivity: Double?) async throws -> DiabetesPredictionResponse {
        
        guard let url = URL(string: "\(baseURL)/predict-diabetes") else {
            throw URLError(.badURL)
        }
        
        // Calculate BMI
        let heightM = (healthProfile.height ?? 170) / 100
        let bmi = (healthProfile.weight ?? 70) / (heightM * heightM)
        
        // Convert age to category (1-13)
        let ageCategory = min(13, max(1, (healthProfile.age ?? 30) / 5))
        
        // Convert health ratings (1-5) to days (0-30)
        let mentalHealthDays = Int((Double(healthProfile.mentalHealth ?? 3) - 1) * 7.5)
        let physicalHealthDays = Int((Double(healthProfile.physicalHealth ?? 3) - 1) * 7.5)
        
        // Gender: 0=female, 1=male
        let genderCode = healthProfile.gender?.lowercased() == "male" ? 1 : 0
        
        // Physical activity: 0=none, 1=any
        let hasPhysicalActivity = (physicalActivity ?? 0) > 0 ? 1 : 0
        
        // Create BRFSS format request
        let requestBody: [String: Any] = [
            "high_bp": healthProfile.highBP ?? false ? 1 : 0,
            "high_chol": healthProfile.cholesterolLevel?.rawValue == "High" ? 1 : 0,
            "chol_check": healthProfile.cholesterolLevel?.rawValue != "N/A" ? 1 : 0,
            "bmi": bmi,
            "smoker": healthProfile.smoking ?? false ? 1 : 0,
            "stroke": 0,
            "heart_disease": healthProfile.heartDisease ?? false ? 1 : 0,
            "physical_activity": hasPhysicalActivity,
            "fruits": healthProfile.eatFruitPerDay ?? false ? 1 : 0,
            "veggies": healthProfile.eatVegetablePerDay ?? false ? 1 : 0,
            "heavy_alcohol": healthProfile.alcohol ?? false ? 1 : 0,
            "health_insurance": 1,
            "no_doctor_cost": 0,
            "general_health": healthProfile.generalHealth ?? 3,
            "mental_health": mentalHealthDays,
            "physical_health": physicalHealthDays,
            "difficulty_walking": healthProfile.difficultyWalking ?? false ? 1 : 0,
            "gender": genderCode,
            "age": ageCategory,
            "education": healthProfile.education ?? 4,
            "income": healthProfile.income ?? 4
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let predictionResponse = try decoder.decode(DiabetesPredictionResponse.self, from: data)
        
        return predictionResponse
    }
    
    func checkRisk(healthProfile: HealthProfile, physicalActivity: Double?) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await predictDiabetesRisk(
                    healthProfile: healthProfile,
                    physicalActivity: physicalActivity
                )
                
                await MainActor.run {
                    self.prediction = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to get prediction: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Diabetes Prediction Result View

struct DiabetesPredictionView: View {
    @StateObject private var predictionService = DiabetesPredictionService()
    let healthProfile: HealthProfile
    @Binding var isPresented: Bool
    let physicalActivity: Double
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if predictionService.isLoading {
                        loadingView
                    } else if let prediction = predictionService.prediction {
                        resultView(prediction: prediction)
                    } else if let error = predictionService.errorMessage {
                        errorView(message: error)
                    } else {
                        checkButton
                    }
                }
                .padding()
            }
            .navigationTitle("Diabetes Risk Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            if predictionService.prediction == nil && !predictionService.isLoading {
                predictionService.checkRisk(
                    healthProfile: healthProfile,
                    physicalActivity: physicalActivity
                )
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing your health data...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Result View
    
    private func resultView(prediction: DiabetesPredictionResponse) -> some View {
        VStack(spacing: 24) {
            // Risk Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(prediction.riskScore) / 100)
                    .stroke(
                        riskColor(for: prediction.riskLevel),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(prediction.riskScore)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(riskColor(for: prediction.riskLevel))
                    
                    Text("Risk Score")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Risk Level
            Text(prediction.riskLevel.uppercased())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(riskColor(for: prediction.riskLevel))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(riskColor(for: prediction.riskLevel).opacity(0.1))
                )
            
            Text(prediction.prediction)
                .font(.headline)
                .foregroundColor(.gray)
            
            // Risk Factors
            if !prediction.riskFactors.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Risk Factors")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(prediction.riskFactors, id: \.self) { factor in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text(factor)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.05))
                )
            }
            
            // Recommendations
            if !prediction.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommendations")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(prediction.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(recommendation)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.05))
                )
            }
            
            // Check Again Button
            Button(action: {
                predictionService.checkRisk(
                    healthProfile: healthProfile,
                    physicalActivity: physicalActivity
                )
            }) {
                Text("Check Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: {
                predictionService.checkRisk(
                    healthProfile: healthProfile,
                    physicalActivity: physicalActivity
                )
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
        }
        .padding()
    }
    
    // MARK: - Check Button
    
    private var checkButton: some View {
        Button(action: {
            predictionService.checkRisk(
                healthProfile: healthProfile,
                physicalActivity: physicalActivity
            )
        }) {
            Text("Check My Risk")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.purple)
                .cornerRadius(16)
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    
    private func riskColor(for level: String) -> Color {
        switch level.lowercased() {
        case "low":
            return .green
        case "moderate":
            return .orange
        case "high":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    DiabetesPredictionView(
        healthProfile: HealthProfile(),
        isPresented: .constant(true),
        physicalActivity: 30
    )
}
