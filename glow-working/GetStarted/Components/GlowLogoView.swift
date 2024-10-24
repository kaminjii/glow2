import SwiftUI

struct GlowLogoView: View {
    var body: some View {
        Image("glowLogoWhite")
            .resizable()
            .scaledToFit()
            .frame(width: 172)
            .padding()
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    GlowLogoView()
}
