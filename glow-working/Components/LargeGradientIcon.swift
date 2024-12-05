import SwiftUI

// A view that displays an large icon with a gradient background
struct LargeGradientIcon: View {
    var iconName: String // The name of the SF Symbol icon to display

    var body: some View {
        ZStack {
            // Gradient background for the icon
            LinearGradient(
                gradient: Gradient(colors: [Color.yellowGradientStart, Color.yellowGradientEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Icon overlay
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundColor(.black1)
        }
        .frame(width: 80, height: 80)
        .cornerRadius(50)
    }
}

#Preview {
    LargeGradientIcon(iconName: "figure.run")
}
