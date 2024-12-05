//
//  AnimatedBackgroundView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/1/24.
//

import SwiftUI

// Main view that displays the animated star field
struct AnimatedStarField: View {
    @StateObject private var state = StarFieldState()  // Creating an observable object to manage the star field state
    
    var body: some View {
        ZStack {
            Color.whitePrimary.ignoresSafeArea()  // Background color of the view, stretching to cover the entire screen
            
            // Iterating over each star in the state and creating a StarView for each
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


// Preview for the AnimatedStarField view
#Preview {
    AnimatedStarField()
}
