import SwiftUI

struct GetStartedView: View {
    @State private var navigateToLoginOrRegister = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                GetStartedBackground()

                VStack {
                    Spacer()
                    GlowLogoView()
                    Spacer()
                }

                VStack {
                    Spacer()
                    TaglineText()
                    Spacer()
                }

                VStack {
                    Spacer()
                    // Button action triggers navigation
                    GradientButton(title: "Get Started", action: {
                        navigateToLoginOrRegister = true
                    }, isEnabled: true)
                    .padding(.bottom, 40)
                    .padding(.horizontal)
                }
            }
            .ignoresSafeArea(edges: .all)
            .background(.yellow1)
            
            .navigationDestination(isPresented: $navigateToLoginOrRegister) {
                LoginOrRegisterView()
            }
        }
    }
}

#Preview {
    GetStartedView()
}
