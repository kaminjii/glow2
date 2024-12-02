//
//  AnimatedBackgroundView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/1/24.
//

import SwiftUI

class StarFieldState: ObservableObject {
    struct Star: Identifiable {
        let id = UUID()
        let size: CGFloat
        let position: CGPoint
        let delay: Double
    }
    
    let stars: [Star]
    
    init() {
        var starPositions: [Star] = []
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Helper function to add a star in a specific region
        func addStar(xRange: ClosedRange<CGFloat>, yRange: ClosedRange<CGFloat>) -> Star {
            let size = CGFloat.random(in: 10...16)
            let x = screenWidth * CGFloat.random(in: xRange)
            let y = screenHeight * CGFloat.random(in: yRange)
            let delay = Double.random(in: 0...1.0)
            return Star(size: size, position: CGPoint(x: x, y: y), delay: delay)
        }
        
        // Top edge stars
        for _ in 0..<3 {
            starPositions.append(addStar(xRange: 0.1...0.9, yRange: 0.05...0.15))
        }
        
        // Bottom edge stars
        for _ in 0..<3 {
            starPositions.append(addStar(xRange: 0.1...0.9, yRange: 0.85...0.95))
        }
        
        // Left edge stars
        for _ in 0..<2 {
            starPositions.append(addStar(xRange: 0.05...0.15, yRange: 0.2...0.8))
        }
        
        // Right edge stars
        for _ in 0..<2 {
            starPositions.append(addStar(xRange: 0.85...0.95, yRange: 0.2...0.8))
        }
        
        stars = starPositions
    }
}

struct AnimatedStarField: View {
    @StateObject private var state = StarFieldState()
    
    var body: some View {
        ZStack {
            Color.whitePrimary.ignoresSafeArea()
            
            ForEach(state.stars) { star in
                StarView(
                    size: star.size,
                    position: star.position,
                    delay: star.delay
                )
            }
        }
    }
}

struct StarView: View {
    let size: CGFloat
    let position: CGPoint
    let delay: Double
    
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .position(x: position.x + xOffset, y: position.y + yOffset)
            .foregroundStyle(.yellow1)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.5...4.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        yOffset = CGFloat.random(in: -15...15)
                        xOffset = CGFloat.random(in: -8...8)
                    }
                    
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.0...3.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        opacity = Double.random(in: 0.4...0.7)
                    }
                    
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.0...3.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        scale = CGFloat.random(in: 0.95...1.05)
                    }
                }
                
                opacity = 0.5
            }
    }
}

#Preview {
    AnimatedStarField()
}
