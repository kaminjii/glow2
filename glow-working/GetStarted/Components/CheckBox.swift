import SwiftUI

struct CheckBoxView: View {
    @Binding var checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .resizable()
            .scaledToFit()
            .frame(width:20, height:20)
            .foregroundColor(checked ? Color(UIColor.blue1) : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
    }
}

#Preview {
    CheckBoxView(checked: .constant(false))
}
