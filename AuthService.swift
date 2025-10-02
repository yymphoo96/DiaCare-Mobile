//
//  AuthService.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 01/10/2025.
//

import Foundation
class AuthService {
    static let shared = AuthService()
    private let baseURL = "http://172.20.10.8:8000" // Change to your API URL
    
    // MARK: - Sign Up
    func signup(name: String, email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "name": name,
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            KeychainManager.shared.saveToken(authResponse.token)
            return authResponse
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw AuthError.serverError(errorResponse?.error ?? "Unknown error")
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            KeychainManager.shared.saveToken(authResponse.token)
            return authResponse
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw AuthError.serverError(errorResponse?.error ?? "Invalid credentials")
        }
    }
    
    // MARK: - Get Profile
    func getProfile() async throws -> User {
        guard let token = KeychainManager.shared.getToken() else {
            throw AuthError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/user/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(User.self, from: data)
        } else {
            throw AuthError.serverError("Failed to fetch profile")
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(name: String) async throws -> User {
        guard let token = KeychainManager.shared.getToken() else {
            throw AuthError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/user/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = ["name": name]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(User.self, from: data)
        } else {
            throw AuthError.serverError("Failed to update profile")
        }
    }
    
    // MARK: - Logout
    func logout() {
        KeychainManager.shared.deleteToken()
    }
    
    // MARK: - Check Auth Status
    func isAuthenticated() -> Bool {
        return KeychainManager.shared.getToken() != nil
    }
}
