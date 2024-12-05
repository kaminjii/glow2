import SwiftUI

// A view that displays an icon with a gradient background
struct GradientIcon: View {
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
                .padding(10)
                .foregroundColor(.black1)
        }
        .frame(width: 50, height: 50)
        .cornerRadius(30)
    }
}

#Preview {
    GradientIcon(iconName: "figure.run")
}
