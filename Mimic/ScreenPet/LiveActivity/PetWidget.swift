import WidgetKit
import SwiftUI
import ActivityKit

// Note: This struct must be the entry point in your Widget Extension.
// If you already have a WidgetBundle, add this widget to it.

struct PetWidget: Widget {
    let kind: String = "PetWidget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetActivityAttributes.self) { context in
            // Lock Screen / Banner View
            PetActivityView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Label("\(Int(context.state.health * 100))%", systemImage: "heart.fill")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label("Time", systemImage: "timer")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    PetExpandedView(state: context.state)
                }
            } compactLeading: {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(colorForHealth(context.state.health))
            } compactTrailing: {
                Gauge(value: context.state.health) {
                    Text("H")
                }
                .gaugeStyle(.accessoryCircular)
            } minimal: {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(colorForHealth(context.state.health))
            }
        }
    }
    
    func colorForHealth(_ health: Double) -> Color {
        switch health {
        case 0.8...1.0: return .green
        case 0.4..<0.8: return .yellow
        case 0.1..<0.4: return .orange
        default: return .red
        }
    }
}

struct PetActivityView: View {
    let state: PetActivityAttributes.ContentState
    
    var body: some View {
        HStack {
            Image(systemName: "pawprint.fill")
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text("Pet is \(state.petState)")
                    .font(.headline)
                ProgressView(value: state.health)
            }
            Text("\(Int(state.health * 100))%")
        }
        .padding()
    }
}

struct PetExpandedView: View {
    let state: PetActivityAttributes.ContentState
    
    var body: some View {
        VStack {
            Text("Keep focusing to heal!")
                .font(.caption)
            // Placeholder for animation
            Image(systemName: "pawprint.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
        }
    }
}
