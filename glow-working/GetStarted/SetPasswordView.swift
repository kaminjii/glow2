import SwiftUI

struct SetPasswordView: View {
    @State var password: String = ""
    @State var confirmPassword: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Sign Up")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .font(.title)

            VStack {
                
                AppTextField(icon: "lock.fill", placeholder: "Password", label: $password)
                    .padding(.top)
                
                AppTextField(icon: "lock.fill", placeholder: "Confirm Password", label: $confirmPassword)
                    .padding(.top)
 
                
                Spacer()
            }
            .frame(height: 250)
            
            GradientButton(title: "Register", action: {}, isEnabled: true)

            Spacer()
        }
        .padding(.horizontal)
        .ignoresSafeArea(edges: .all)
        .background(.whitePrimary)
    }
}

#Preview {
    SetPasswordView()
}
