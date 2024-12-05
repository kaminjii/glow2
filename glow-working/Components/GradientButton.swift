import SwiftUI

// A custom button view with gradient background and state-dependent styling
struct GradientButton: View {
    var title: String // The title text for the button
    var action: () -> Void // The action to execute when the button is tapped
    var isEnabled: Bool // Determines if the button is active or disabled
    
    var body: some View {
        Button(action: {
            // Execute the action only if the button is enabled
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                if isEnabled {
                    // Gradient background when the button is enabled
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blueGradientStart, Color.blueGradientEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .cornerRadius(50)
                } else {
                    // Solid gray background when the button is disabled
                    Color.gray3
                    .cornerRadius(50)
                }
                
                // Text overlay for the button
                Text(title)
                    .foregroundColor(isEnabled ? .white : .gray4)
                    .font(.body)
                    .fontWeight(.heavy)
            }
        }
        .frame(height: 60)
        .shadow(color: isEnabled ? .buttonShadow : .clear, radius: 22, x: 0, y: 10)
        .disabled(!isEnabled)
    }
}


#Preview {
    VStack(spacing: 20) {
        GradientButton(title: "Enabled Button", action: {}, isEnabled: true)
        GradientButton(title: "Disabled Button", action: {}, isEnabled: false)
    }
}
