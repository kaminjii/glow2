import SwiftUI

struct RegisterNewUserView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Sign Up")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .font(.title)

            VStack {
                
                AppTextField(icon: "person.fill", placeholder: "Email", label: $firstName)
                    .padding(.top)
                
                AppTextField(icon: "person.fill", placeholder: "Password", label: $lastName)
                    .padding(.top)
                
                AppTextField(icon: "envelope.fill", placeholder: "Password", label: $email)
                    .padding(.top)
                
                Spacer()
            }
            .frame(height: 250)
            
            GradientButton(title: "Continue", action: {}, isEnabled: true)

            Spacer()
        }
        .padding(.horizontal)
        .ignoresSafeArea(edges: .all)
        .background(.whitePrimary)
    }
}

#Preview {
    RegisterNewUserView()
}
