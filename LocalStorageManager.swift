//
//  LocalStorageManager.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 02/01/2026.
//

import Foundation

class LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private let currentUserKey = "currentUser"
    private let authTokenKey = "authToken"
    private let isAuthenticatedKey = "isAuthenticated"
    private let lastSyncDateKey = "lastHealthSyncDate"
    
    private init() {}
    
    // MARK: - User Management
    
    func saveUser(_ user: User) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(user)
            userDefaults.set(encoded, forKey: currentUserKey)
            userDefaults.synchronize() // Force immediate save
            print("✅ User saved to local storage")
        } catch {
            print("❌ Failed to save user: \(error)")
        }
    }
    
    func loadUser() -> User? {
        guard let data = userDefaults.data(forKey: currentUserKey) else {
            print("⚠️ No user data found in local storage")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: data)
            print("✅ User loaded from local storage: \(user.name)")
            return user
        } catch {
            print("❌ Failed to load user: \(error)")
            return nil
        }
    }
    
    func deleteUser() {
        userDefaults.removeObject(forKey: currentUserKey)
        userDefaults.synchronize()
        print("✅ User deleted from local storage")
    }
    
    // MARK: - Authentication
    
    func saveAuthToken(_ token: String) {
        userDefaults.set(token, forKey: authTokenKey)
        userDefaults.synchronize()
    }
    
    func loadAuthToken() -> String? {
        return userDefaults.string(forKey: authTokenKey)
    }
    
    func deleteAuthToken() {
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.synchronize()
    }
    
    func setAuthenticated(_ isAuthenticated: Bool) {
        userDefaults.set(isAuthenticated, forKey: isAuthenticatedKey)
        userDefaults.synchronize()
    }
    
    func isAuthenticated() -> Bool {
        return userDefaults.bool(forKey: isAuthenticatedKey)
    }
    
    // MARK: - Health Sync Date
    
    func saveLastSyncDate(_ date: Date) {
        userDefaults.set(date, forKey: lastSyncDateKey)
        userDefaults.synchronize()
    }
    
    func loadLastSyncDate() -> Date? {
        return userDefaults.object(forKey: lastSyncDateKey) as? Date
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        userDefaults.removeObject(forKey: currentUserKey)
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.removeObject(forKey: isAuthenticatedKey)
        userDefaults.removeObject(forKey: lastSyncDateKey)
        userDefaults.synchronize()
        print("✅ All local data cleared")
    }
}
