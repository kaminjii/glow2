//
//  StarFieldView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import Foundation
import SwiftUI

// View representing an individual star with animation properties
struct StarView: View {
    let size: CGFloat  // Size of the star
    let position: CGPoint  // Position of the star on the screen
    let delay: Double  // Delay before the animation starts
    
    @State private var yOffset: CGFloat = 0  // Vertical offset for star animation
    @State private var xOffset: CGFloat = 0  // Horizontal offset for star animation
    @State private var opacity: Double = 0  // Opacity of the star
    @State private var scale: CGFloat = 1.0  // Scale of the star
    
    var body: some View {
        // Image view for the star, using a resizable and scalable "glowStar" image
        Image("glowStar")
            .resizable()  // Makes the image resizable
            .scaledToFit()  // Ensures the image scales uniformly
            .frame(width: size, height: size)  // Sets the frame size of the star
            .position(x: position.x + xOffset, y: position.y + yOffset)  // Sets the position with offsets
            .foregroundStyle(.yellow1)  // Applies a color style to the star
            .opacity(opacity)  // Sets the opacity of the star
            .scaleEffect(scale)  // Sets the scale of the star
            .onAppear {
                // Delay the start of animations by the specified delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Animation for vertical and horizontal movement
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.5...4.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        yOffset = CGFloat.random(in: -15...15)  // Random vertical offset
                        xOffset = CGFloat.random(in: -8...8)  // Random horizontal offset
                    }
                    
                    // Animation for changing opacity
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.0...3.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        opacity = Double.random(in: 0.4...0.7)  // Random opacity
                    }
                    
                    // Animation for changing scale
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.0...3.0))
                        .repeatForever(autoreverses: true)
                    ) {
                        scale = CGFloat.random(in: 0.95...1.05)  // Random scale
                    }
                }
                
                // Initial opacity setting
                opacity = 0.5
            }
    }
}

// Class representing the state of the star field, conforming to ObservableObject for use in SwiftUI views
class StarFieldState: ObservableObject {
    // Struct representing a single star, conforming to Identifiable for use in ForEach
    struct Star: Identifiable {
        let id = UUID()  // Unique identifier for each star
        let size: CGFloat  // Size of the star
        let position: CGPoint  // Position of the star on the screen
        let delay: Double  // Delay before the star starts animating
    }
    
    // Array holding all the stars in the star field
    let stars: [Star]
    
    // Initializer to populate the star field with random star positions and properties
    init() {
        var starPositions: [Star] = []
        let screenWidth = UIScreen.main.bounds.width  // Width of the screen
        let screenHeight = UIScreen.main.bounds.height  // Height of the screen
        
        // Helper function to create a star with random properties within a given range
        func addStar(xRange: ClosedRange<CGFloat>, yRange: ClosedRange<CGFloat>) -> Star {
            let size = CGFloat.random(in: 10...16)  // Random star size
            let x = screenWidth * CGFloat.random(in: xRange)  // Random x position
            let y = screenHeight * CGFloat.random(in: yRange)  // Random y position
            let delay = Double.random(in: 0...1.0)  // Random delay before animation
            return Star(size: size, position: CGPoint(x: x, y: y), delay: delay)
        }
        
        // Adding stars to the top edge of the screen
        for _ in 0..<3 {
            starPositions.append(addStar(xRange: 0.1...0.9, yRange: 0.05...0.15))
        }
        
        // Adding stars to the bottom edge of the screen
        for _ in 0..<3 {
            starPositions.append(addStar(xRange: 0.1...0.9, yRange: 0.85...0.95))
        }
        
        // Adding stars to the left edge of the screen
        for _ in 0..<2 {
            starPositions.append(addStar(xRange: 0.05...0.15, yRange: 0.2...0.8))
        }
        
        // Adding stars to the right edge of the screen
        for _ in 0..<2 {
            starPositions.append(addStar(xRange: 0.85...0.95, yRange: 0.2...0.8))
        }
        
        // Setting the stars array with the generated positions and properties
        stars = starPositions
    }
}
