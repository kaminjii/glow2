import SwiftUI

struct LoginOrRegisterView: View {
    @State private var navigateToLogin: Bool = false
    @State private var navigateToRegister: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .topLeading){
                GetStartedBackground()
                
                
                VStack {
                    Spacer()
                    GlowLogoView()
                    Spacer()
                }
                
                VStack{
                    Spacer()
                    TaglineText()
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    GradientButton(title: "Login", action: {
                        navigateToLogin = true
                    }, isEnabled: true)
                    .padding(.bottom)
                    .padding(.horizontal)
                    
                    GradientButton(title: "Sign Up", action: {
                        navigateToRegister = true
                    }, isEnabled: true)
                    .padding(.bottom, 40)
                    .padding(.horizontal)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginUserView()
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterNewUserView()
            }
            .toolbarVisibility(.hidden)
            .ignoresSafeArea(edges: .all)
            .background(.yellow1)
        }
    }
}

#Preview {
    LoginOrRegisterView()
}
