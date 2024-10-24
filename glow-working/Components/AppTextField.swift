import SwiftUI

struct AppTextField: View {
    var icon: String
    var placeholder: String
    @Binding var label: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.gray1)
                .frame(width: 25)
            
            ZStack {
                if label.isEmpty {
                    Text(placeholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.gray1)
                }
                
                TextField("", text: $label)
                    .autocorrectionDisabled()
                    .font(.body)
                    .foregroundStyle(.black1)
                    .frame(maxWidth: .infinity)
            }
                
        }
        .padding()
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.gray2)))
    }
}

#Preview {
    AppTextField(icon: "envelope.fill", placeholder: "Email", label: .constant(""))
}
