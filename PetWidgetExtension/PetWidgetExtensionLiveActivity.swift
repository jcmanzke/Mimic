//
//  PetWidgetExtensionLiveActivity.swift
//  PetWidgetExtension
//
//  Created by Christian Manzke on 2/7/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PetWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetActivityAttributes.self) { context in
            // MARK: - Lock Screen / Banner View
            HStack(spacing: 16) {
                // Pet image
                Image(context.state.petImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(context.attributes.petName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(context.state.health * 100))%")
                            .font(.title3.bold())
                            .foregroundColor(colorForHealth(context.state.health))
                    }
                    
                    // Health bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(colorForHealth(context.state.health))
                                .frame(width: max(0, geo.size.width * context.state.health), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Text(context.state.petState)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(16)
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    Image(context.state.petImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(context.state.health * 100))%")
                            .font(.title2.bold())
                            .foregroundColor(colorForHealth(context.state.health))
                        
                        Text("Health")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.petName)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Health bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(colorForHealth(context.state.health))
                                    .frame(width: max(0, geo.size.width * context.state.health), height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text(context.state.petState)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // MARK: - Compact Leading — Lumi's face
                Image(context.state.petImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            } compactTrailing: {
                // MARK: - Compact Trailing — Health gauge
                Gauge(value: context.state.health) {
                    Text("")
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(colorForHealth(context.state.health))
                .scaleEffect(0.6)
                .frame(width: 24, height: 24)
            } minimal: {
                // MARK: - Minimal — Small Lumi
                Image(context.state.petImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
            }
            .widgetURL(URL(string: "mimic://dashboard"))
        }
    }
    
    /// Maps health value to a color for visual feedback
    private func colorForHealth(_ health: Double) -> Color {
        switch health {
        case 0.8...1.0: return .green
        case 0.4..<0.8: return .yellow
        case 0.1..<0.4: return .orange
        default: return .red
        }
    }
}

// MARK: - Previews

extension PetActivityAttributes {
    fileprivate static var preview: PetActivityAttributes {
        PetActivityAttributes(petName: "Lumi")
    }
}

extension PetActivityAttributes.ContentState {
    fileprivate static var happy: PetActivityAttributes.ContentState {
        PetActivityAttributes.ContentState(health: 0.92, petState: "Happy & Thriving ✨")
    }
    
    fileprivate static var critical: PetActivityAttributes.ContentState {
        PetActivityAttributes.ContentState(health: 0.08, petState: "Needs help! 💔")
    }
}

#Preview("Notification", as: .content, using: PetActivityAttributes.preview) {
   PetWidgetExtensionLiveActivity()
} contentStates: {
    PetActivityAttributes.ContentState.happy
    PetActivityAttributes.ContentState.critical
}
