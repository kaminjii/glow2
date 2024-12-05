import SwiftUI

// A view to display a horizontal progress bar
struct ProgressBar: View {
    var progress: CGFloat // Represents the progress as a fraction (0.0 to 1.0)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar representing the full progress range
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray3)
                    .frame(width: geometry.size.width, height: 15)

                // Foreground bar representing the current progress
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(   // Adds a gradient fill for the progress
                        gradient: Gradient(colors: [Color.blueGradientStart, Color.blueGradientEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: min(progress * geometry.size.width, geometry.size.width), height: 15) // Dynamically adjusts width based on progress
            }
        }
        .frame(height: 15)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.25)
            .frame(width: 300)
        ProgressBar(progress: 0.5)
            .frame(width: 300)
        ProgressBar(progress: 0.75)
            .frame(width: 300)
        ProgressBar(progress: 1.0)
            .frame(width: 300)
    }
}
