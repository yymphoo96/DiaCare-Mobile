//
//  HealthProfileBannerView.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 28/11/2025.
//

import SwiftUI

struct HealthProfileBanner: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Complete Your Health Profile")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Help us provide better predictions")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                showSheet = true
            }) {
                Text("Update")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                )
        )
    }
}
