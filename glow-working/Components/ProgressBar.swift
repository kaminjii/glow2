import SwiftUI

struct ProgressBar: View {
    var progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray3)
                    .frame(width: geometry.size.width, height: 15)

                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blueGradientStart, Color.blueGradientEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: min(progress * geometry.size.width, geometry.size.width), height: 15)
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
