//
//  StatCard.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 02/12/2025.
//

import SwiftUI

// MARK: - Stat Card for Activity Stats (with icon)

struct ActivityStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Stat Card for Profile Stats (without icon)

//struct StatCard: View {
//    let value: String
//    let label: String
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            Text(value)
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(color.opacity(0.15))
//        )
//    }
//}
