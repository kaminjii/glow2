import SwiftUI

struct GetStartedBackground: View {
    var body: some View {
        BackgroundImage(imageName: "backgroundStars1", width: 320, alignment: .topLeading)
        BackgroundImage(imageName: "backgroundStars2", width: 115, alignment: .topTrailing, offsetY: 197)
        BackgroundImage(imageName: "backgroundStars3", width: 300, alignment: .bottomLeading)
    }
}

#Preview {
    VStack {
        GetStartedBackground()
    }
    .ignoresSafeArea(edges: .all)
    .background(.yellow1)
}
