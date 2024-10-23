import SwiftUI

struct GradientButton: View {
    var title: String
    var action: () -> Void
    var isEnabled: Bool
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                if isEnabled {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blueGradientStart, Color.blueGradientEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .cornerRadius(50)
                } else {
                    Color.gray3
                    .cornerRadius(50)
                }
                
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
