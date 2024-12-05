import SwiftUI

struct GetStartedView: View {
    // State variables to manage navigation to Login and SignUp views.
    @State private var navigateToLogin = false
    @State private var navigateToSignUp = false
    
    // StateObject for managing authentication logic.
    @StateObject private var authenticationViewModel = AuthenticationViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                // Sets a yellow background color that extends to the entire screen.
                Color.yellow1.ignoresSafeArea(.all)
                
                // Custom background overlay
                GetStartedBackground().ignoresSafeArea(.all)

                // Main content container for the "Get Started" screen.

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
                
                
                // Container for the buttons and interactions.
                VStack {
                    Spacer()
                    GradientButton(title: "Get Started", action: {
                        // Sets the state to navigate to the SignUp view.
                        navigateToSignUp = true
                    }, isEnabled: true)
                    .padding(.horizontal, 20)
                    
                    // Button for navigating to the Login view.
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
            // Navigation logic for transitioning to the Login view.
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginUserView()
            }
            // Navigation logic for transitioning to the SignUp view, passing in the authentication view model.
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
