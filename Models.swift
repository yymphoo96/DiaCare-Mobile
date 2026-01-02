//
//  Models.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 01/10/2025.
//

import Foundation

// MARK: - Models
struct User: Codable, Identifiable {
    let id: String?
    let name: String
    let email: String
    var healthProfile: HealthProfile?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case healthProfile
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct UpdateProfileRequest: Codable {
    let name: String
}

struct ErrorResponse: Codable {
    let error: String
}



struct HealthProfile: Codable {
    var gender: String?
    var age: Int?
    var height: Double? // in cm
    var weight: Double? // in kg
    var familyHistoryDiabetes: Bool?
    var highBP: Bool?
    var cholesterolLevel: CholesterolLevel?
    var smoking: Bool?
    var heartDisease: Bool?
    var dietHealthy: Bool?
    var eatFruitPerDay: Bool?
    var eatVegetablePerDay: Bool?
    var alcohol: Bool?
    var generalHealth: Int? // 1-5
    var mentalHealth: Int? // 1-5
    var physicalHealth: Int? // 1-5
    var difficultyWalking: Bool?
    var stressLevel: StressLevel?
    var sleepHours: Double?
    var education: Int?
    var income: Int?
    
    var isComplete: Bool {
        return gender != nil && age != nil && height != nil && weight != nil &&
               familyHistoryDiabetes != nil && highBP != nil && cholesterolLevel != nil &&
               smoking != nil && heartDisease != nil && dietHealthy != nil &&
               eatFruitPerDay != nil && eatVegetablePerDay != nil && alcohol != nil &&
               generalHealth != nil && mentalHealth != nil && physicalHealth != nil &&
               difficultyWalking != nil && stressLevel != nil && sleepHours != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case gender, age, height, weight
        case familyHistoryDiabetes = "family_history_diabetes"
        case highBP = "high_bp"
        case cholesterolLevel = "cholesterol_level"
        case smoking
        case heartDisease = "heart_disease"
        case dietHealthy = "diet_healthy"
        case eatFruitPerDay = "eat_fruit_per_day"
        case eatVegetablePerDay = "eat_vegetable_per_day"
        case alcohol
        case generalHealth = "general_health"
        case mentalHealth = "mental_health"
        case physicalHealth = "physical_health"
        case difficultyWalking = "difficulty_walking"
        case stressLevel = "stress_level"
        case sleepHours = "sleep_hours"
        case education
        case income
    }
}

enum CholesterolLevel: String, Codable, CaseIterable {
    case high = "High"
    case low = "Low"
    case normal = "Normal"
    case na = "N/A"
}

enum StressLevel: String, Codable, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}
