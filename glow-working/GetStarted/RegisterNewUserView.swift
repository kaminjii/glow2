import SwiftUI

struct RegisterNewUserView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State private var continueClicked: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Sign Up")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .font(.title)
                
                VStack {
                    
                    AppTextField(icon: "person.fill", placeholder: "First Name", label: $firstName)
                        .padding(.top)
                    
                    AppTextField(icon: "person.fill", placeholder: "Last Name", label: $lastName)
                        .padding(.top)
                    
                    AppTextField(icon: "envelope.fill", placeholder: "Email", label: $email)
                        .padding(.top)
                    
                    Spacer()
                }
                .frame(height: 250)
                
                GradientButton(title: "Continue", action: {
                    continueClicked = true
                }, isEnabled: true)
                
                Spacer()
            }
            .padding(.horizontal)
            .ignoresSafeArea(edges: .all)
            .background(.whitePrimary)
            .navigationDestination(isPresented: $continueClicked) {
                SetPasswordView()
            }
            .toolbarVisibility(.hidden)
            
        }
    }
}

#Preview {
    RegisterNewUserView()
}
