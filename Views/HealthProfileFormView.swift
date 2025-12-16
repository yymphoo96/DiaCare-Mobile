//
//  HealthProfile.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 28/11/2025.
//

import SwiftUI

struct HealthProfileFormView: View {
    @Binding var user: User?
    @Binding var isPresented: Bool
    
    @State private var gender = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var familyHistoryDiabetes = false
    @State private var highBP = false
    @State private var cholesterolLevel: CholesterolLevel = .normal
    @State private var smoking = false
    @State private var heartDisease = false
    @State private var dietHealthy = false
    @State private var eatFruitPerDay = false
    @State private var eatVegetablePerDay = false
    @State private var alcohol = false
    @State private var generalHealth = 3
    @State private var mentalHealth = 3
    @State private var physicalHealth = 3
    @State private var difficultyWalking = false
    @State private var stressLevel: StressLevel = .moderate
    @State private var sleepHours = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    Picker("Gender", selection: $gender) {
                        Text("Select").tag("")
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Medical History")) {
                    Toggle("Family History of Diabetes", isOn: $familyHistoryDiabetes)
                    Toggle("High Blood Pressure", isOn: $highBP)
                    
                    Picker("Cholesterol Level", selection: $cholesterolLevel) {
                        ForEach(CholesterolLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Toggle("Smoking", isOn: $smoking)
                    Toggle("Heart Disease", isOn: $heartDisease)
                }
                
                Section(header: Text("Lifestyle")) {
                    Toggle("Healthy Diet", isOn: $dietHealthy)
                    Toggle("Eat Fruit Daily", isOn: $eatFruitPerDay)
                    Toggle("Eat Vegetables Daily", isOn: $eatVegetablePerDay)
                    Toggle("Alcohol Consumption", isOn: $alcohol)
                    
                    Picker("Stress Level", selection: $stressLevel) {
                        ForEach(StressLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    TextField("Sleep Hours per Day", text: $sleepHours)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Health Ratings (1-5)")) {
                    VStack(alignment: .leading) {
                        Text("General Health: \(generalHealth)")
                        Slider(value: Binding(
                            get: { Double(generalHealth) },
                            set: { generalHealth = Int($0) }
                        ), in: 1...5, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Mental Health: \(mentalHealth)")
                        Slider(value: Binding(
                            get: { Double(mentalHealth) },
                            set: { mentalHealth = Int($0) }
                        ), in: 1...5, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Physical Health: \(physicalHealth)")
                        Slider(value: Binding(
                            get: { Double(physicalHealth) },
                            set: { physicalHealth = Int($0) }
                        ), in: 1...5, step: 1)
                    }
                    
                    Toggle("Difficulty Walking", isOn: $difficultyWalking)
                }
            }
            .navigationTitle("Health Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHealthProfile()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadExistingProfile()
            }
        }
    }
    
    private func loadExistingProfile() {
        if let profile = user?.healthProfile {
            gender = profile.gender ?? ""
            age = profile.age.map { String($0) } ?? ""
            height = profile.height.map { String($0) } ?? ""
            weight = profile.weight.map { String($0) } ?? ""
            familyHistoryDiabetes = profile.familyHistoryDiabetes ?? false
            highBP = profile.highBP ?? false
            cholesterolLevel = profile.cholesterolLevel ?? .normal
            smoking = profile.smoking ?? false
            heartDisease = profile.heartDisease ?? false
            dietHealthy = profile.dietHealthy ?? false
            eatFruitPerDay = profile.eatFruitPerDay ?? false
            eatVegetablePerDay = profile.eatVegetablePerDay ?? false
            alcohol = profile.alcohol ?? false
            generalHealth = profile.generalHealth ?? 3
            mentalHealth = profile.mentalHealth ?? 3
            physicalHealth = profile.physicalHealth ?? 3
            difficultyWalking = profile.difficultyWalking ?? false
            stressLevel = profile.stressLevel ?? .moderate
            sleepHours = profile.sleepHours.map { String($0) } ?? ""
        }
    }
    
    private func saveHealthProfile() {
        let profile = HealthProfile(
            gender: gender.isEmpty ? nil : gender,
            age: Int(age),
            height: Double(height),
            weight: Double(weight),
            familyHistoryDiabetes: familyHistoryDiabetes,
            highBP: highBP,
            cholesterolLevel: cholesterolLevel,
            smoking: smoking,
            heartDisease: heartDisease,
            dietHealthy: dietHealthy,
            eatFruitPerDay: eatFruitPerDay,
            eatVegetablePerDay: eatVegetablePerDay,
            alcohol: alcohol,
            generalHealth: generalHealth,
            mentalHealth: mentalHealth,
            physicalHealth: physicalHealth,
            difficultyWalking: difficultyWalking,
            stressLevel: stressLevel,
            sleepHours: Double(sleepHours)
        )
        
        user?.healthProfile = profile
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
        
        // TODO: Send to backend API
        // Task {
        //     try await AuthService.shared.updateHealthProfile(profile)
        // }
        
        isPresented = false
    }
}
