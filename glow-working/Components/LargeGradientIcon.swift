import SwiftUI

struct LargeGradientIcon: View {
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
