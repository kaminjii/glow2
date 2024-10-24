import SwiftUI

struct LoginOrRegisterView: View {
    var body: some View {
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
                
                GradientButton(title: "Login", action: {}, isEnabled: true)
                    .padding(.bottom)
                    .padding(.horizontal)
                
                GradientButton(title: "Register", action: {}, isEnabled: true)
                    .padding(.bottom, 40)
                    .padding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .all)
        .background(.yellow1)
    }
}

#Preview {
    LoginOrRegisterView()
}
