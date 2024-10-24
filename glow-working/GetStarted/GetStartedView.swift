import SwiftUI

struct GetStartedView: View {
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
                
                GradientButton(title: "Get Started", action: {}, isEnabled: true)
                    .padding(.bottom, 40)
                    .padding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .all)
        .background(.yellow1)
    }
}

#Preview {
    GetStartedView()
}
