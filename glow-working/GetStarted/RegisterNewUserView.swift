import SwiftUI

struct RegisterNewUserView: View {
    @State var fullName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State private var signUpClicked: Bool = false
    @State private var navigateToLogin: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Sign Up")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(.title)
                
                VStack {
                    AppTextField(icon: "person.fill", placeholder: "Full Name", label: $fullName)
                        .padding(.top)
                    
                    AppTextField(icon: "envelope.fill", placeholder: "Email", label: $email)
                        .padding(.top)
                    
                    AppTextField(icon: "lock.fill", placeholder: "Password", label: $password)
                        .padding(.top)
                    
                    AppTextField(icon: "lock.fill", placeholder: "Confirm Password", label: $confirmPassword)
                        .padding(.top)
                    
                }
                
                GradientButton(title: "Sign Up", action: {
                    signUpClicked = true
                }, isEnabled: true)
                .padding(.top)
                
                Spacer()
                
                Button(action: {
                    navigateToLogin = true
                }) {
                    HStack(spacing: 5) {
                        Text("Already have an account? ")
                            .bold()
                            .foregroundStyle(Color.gray1)
                        Text("Login")
                            .bold()
                            .foregroundStyle(Color.blue1)
                    }
                }
                .padding()
            }
            .padding()
            .ignoresSafeArea(edges: .all)
            .background(.whitePrimary)
            .navigationDestination(isPresented: $signUpClicked) {
                SelectTemplateGoalsView()
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginUserView()
            }
            .toolbarVisibility(.hidden)
            
        }
    }
}

#Preview {
    RegisterNewUserView()
}
