import SwiftUI

struct GetStartedView: View {
    @State private var navigateToLogin = false
    @State private var navigateToSignUp = false
    @StateObject private var authenticationViewModel = AuthenticationViewModel()

    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color.yellow1.ignoresSafeArea(.all)
                GetStartedBackground().ignoresSafeArea(.all)

                VStack {
                    Spacer()
                    glowLogo
                    taglineText
                    Spacer()
                }

                VStack {
                    Spacer()
                    Spacer()
                }

                VStack {
                    Spacer()
                    GradientButton(title: "Get Started", action: {
                        navigateToSignUp = true
                    }, isEnabled: true)
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        HStack(spacing: 5) {
                            Text("Already have an account? ")
                                .foregroundStyle(Color.gray1)
                            Text("Login")
                                .bold()
                                .foregroundStyle(Color.blue1)
                        }
                    }
                    .padding()
                }
            }
            
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginUserView()
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                RegisterInfoView()
                    .environmentObject(authenticationViewModel)
            }
        }
    }
    
    var glowLogo: some View {
        Image("glowLogoWhite")
            .resizable()
            .scaledToFit()
            .frame(width: 172)
            .frame(maxWidth: .infinity)
    }
    
    var taglineText: some View {
        Text("Small steps turn into big growth")
            .font(.headline)
            .foregroundStyle(Color.gray1)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    GetStartedView()
}
