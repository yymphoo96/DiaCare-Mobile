//
//  Models.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 01/10/2025.
//

import Foundation
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct ErrorResponse: Codable {
    let error: String
}
