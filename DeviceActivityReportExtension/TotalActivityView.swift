//
//  TotalActivityView.swift
//  DeviceActivityReportExtension
//

import SwiftUI
import DeviceActivity

struct TotalActivityView: View {
    let totalDurationString: String
    let totalPickups: Int
    
    // Hardcoded colors to match DesignSystem.swift safely without target membership issues
    let brandRed = Color(red: 235/255, green: 94/255, blue: 85/255) // #EB5E55
    let textPrimary = Color(red: 45/255, green: 52/255, blue: 54/255) // #2D3436
    let textSecondary = Color(red: 99/255, green: 110/255, blue: 114/255) // #636E72
    let warningBronze = Color(red: 159/255, green: 116/255, blue: 70/255) // #9F7446
    
    var body: some View {
        HStack(spacing: 16) {
            // Screen Time Card
            ReportStatCard(
                iconName: "chart.bar.xaxis",
                iconColor: brandRed,
                value: totalDurationString,
                subtitle: "Screen Time",
                textPrimary: textPrimary,
                textSecondary: textSecondary
            )
            
            // Pickups Card
            ReportStatCard(
                iconName: "bell.badge",
                iconColor: warningBronze,
                value: "\(totalPickups)",
                subtitle: "Pickups Today",
                textPrimary: textPrimary,
                textSecondary: textSecondary
            )
        }
    }
}

struct ReportStatCard: View {
    let iconName: String
    let iconColor: Color
    let value: String
    let subtitle: String
    
    let textPrimary: Color
    let textSecondary: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.custom("PlusJakartaSans-Regular", size: 22).weight(.bold))
                    // Fallback if font isn't copied to the target
                    .font(.system(size: 22, weight: .bold, design: .rounded)) 
                    .foregroundColor(textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(subtitle)
                    .font(.custom("PlusJakartaSans-Regular", size: 12))
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }
}
