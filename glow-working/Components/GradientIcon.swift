import SwiftUI

struct GradientIcon: View {
    var iconName: String
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.yellowGradientStart, Color.yellowGradientEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
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
