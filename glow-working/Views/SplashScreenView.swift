//
//  SplashScreenView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 10/23/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive : Bool = false
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        if isActive {
            GetStartedView()
        } else {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                Image("glowLogoYellow")
            }
            .onAppear {
                viewModel.setupDailyLogAndGoals()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
