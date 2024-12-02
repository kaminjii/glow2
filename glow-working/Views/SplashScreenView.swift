import SwiftUI
import CoreGraphics

struct SplashScreenView: View {
    @State var isActive: Bool = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // Animation states
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var starOpacity: Double = 0
    @State private var starScale: CGFloat = 0.1
    @State private var particlesOpacity: Double = 0
    
    var body: some View {
        if !isActive {
            ZStack {
                // Background with gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue1, .whitePrimary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Particle effects
                ForEach(0..<12) { index in
                    Circle()
                        .fill(particleColor(index))
                        .frame(width: 8, height: 8)
                        .offset(particleOffset(index))
                        .opacity(particlesOpacity)
                        .animation(
                            Animation
                                .easeInOut(duration: 1)
                                .repeatForever()
                                .delay(Double(index) * 0.1),
                            value: particlesOpacity
                        )
                }
                
                // Stars background
                ForEach(0..<5) { index in
                    Image("star\(index + 1)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .offset(starOffset(index))
                        .opacity(starOpacity)
                        .scaleEffect(starScale)
                        .animation(
                            Animation
                                .easeInOut(duration: 1)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: starOpacity
                        )
                }
                
                // Main logo
                VStack(spacing: 20) {
                    Image("glowLogoYellow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .rotationEffect(.degrees(rotationAngle))
                }
            }
            .onAppear {
                animateSplash()
                
                // Navigate after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        } else {
            // Authentication navigation
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
    
    private func animateSplash() {
        // Logo animation
        withAnimation(.spring(duration: 1)) {
            logoScale = 1
            logoOpacity = 1
            rotationAngle = 360
        }
        
        // Stars animation
        withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
            starOpacity = 0.7
            starScale = 1
        }
        
        // Particles animation
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            particlesOpacity = 0.7
        }
    }
    
    private func particleColor(_ index: Int) -> Color {
        let colors: [Color] = [.yellow, .blue1, .orange, .blue]
        return colors[index % colors.count]
    }
    
    private func particleOffset(_ index: Int) -> CGSize {
        let angle = Double(index) * .pi * 2 / 12
        let radius: CGFloat = 100
        return CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius
        )
    }
    
    private func starOffset(_ index: Int) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -100, height: -120),
            CGSize(width: 100, height: -80),
            CGSize(width: -80, height: 100),
            CGSize(width: 120, height: 60),
            CGSize(width: 0, height: -150)
        ]
        return positions[index]
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AuthenticationViewModel())
}
