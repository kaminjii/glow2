import SwiftUI

struct SetPasswordView: View {
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var passwordSet: Bool = false
    
    var body: some View {
        NavigationStack {
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
                
                GradientButton(title: "Register", action: {
                    passwordSet = true
                }, isEnabled: true)
                
                Spacer()
            }
            .padding(.horizontal)
            .ignoresSafeArea(edges: .all)
            .background(.whitePrimary)
            .navigationDestination(isPresented: $passwordSet) {
                SelectTemplateGoalsView()
            }
            .toolbarVisibility(.hidden)
        }
    }
}

#Preview {
    SetPasswordView()
}
