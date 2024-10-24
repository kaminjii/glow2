import SwiftUI

struct TaglineText: View {
    var body: some View {
        Text("Small steps turn into big growth")
            .font(.headline)
            .foregroundStyle(Color.gray1)
            .offset(y: 60)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    TaglineText()
}
