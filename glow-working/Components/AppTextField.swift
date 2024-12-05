import SwiftUI

// A reusable view representing a customizable text field with an icon
struct AppTextField: View {
    var icon: String // System icon name to display next to the text field
   var placeholder: String // Placeholder text when the field is empty
   var isSecure: Bool = false // Indicates whether the field should obscure input (e.g., for passwords)
   @Binding var label: String // Two-way binding for the text field value
   
   @FocusState private var isFocused: Bool // State variable to manage focus on the text field
    
    var body: some View {
        HStack {
            // Icon on the left side of the text field
            Image(systemName: icon)
                .foregroundStyle(.gray1)
                .frame(width: 25)
            
            ZStack {
                if label.isEmpty {
                    // Show placeholder text when the field is empty
                    Text(placeholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.gray1)
                }
                
                // Display a secure or regular text field based on the `isSecure` flag
                if isSecure {
                    SecureField("", text: $label)
                        .autocorrectionDisabled()
                        .font(.body)
                        .foregroundStyle(.black1)
                        .frame(maxWidth: .infinity)
                } else {
                    TextField("", text: $label)
                        .autocorrectionDisabled()
                        .font(.body)
                        .foregroundStyle(.black1)
                        .frame(maxWidth: .infinity)
                }
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

