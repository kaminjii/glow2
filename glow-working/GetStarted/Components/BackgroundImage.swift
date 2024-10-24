import SwiftUI

struct BackgroundImage: View {
    var imageName: String
    var width: CGFloat
    var alignment: Alignment
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .offset(x: offsetX, y: offsetY)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}
