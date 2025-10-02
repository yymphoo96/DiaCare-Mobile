//
//  AuthError.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 01/10/2025.
//

import Foundation
enum AuthError: LocalizedError {
    case invalidResponse
    case notAuthenticated
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .notAuthenticated:
            return "Not authenticated"
        case .serverError(let message):
            return message
        }
    }
}
