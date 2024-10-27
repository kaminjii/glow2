import SwiftUI

struct AddOtherGoal: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            GradientIcon(iconName: "star.fill")

            VStack(alignment: .leading) {
                Text("Add Other...")
                    .font(.headline)
            }
            .padding(.horizontal, 10)
            
            Spacer()
            Button(action: {
                isPresented = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.gray1)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AddOtherGoal(isPresented: .constant(true))
}
