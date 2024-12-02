import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        if !isActive {
            // Splash Screen
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                Image("glowLogoYellow")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        } else {
            // Navigate based on auth state
            Group {
                switch authViewModel.authenticationState {
                case .authenticated:
                    if authViewModel.hasCompletedOnboarding {
                        ContentView()
                            .environmentObject(authViewModel)
                    } else {
                        SelectTemplateGoalsView()
                            .environmentObject(authViewModel)
                    }
                case .authenticating:
                    ProgressView()
                case .unauthenticated:
                    LoginUserView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AuthenticationViewModel())
}
