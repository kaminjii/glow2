//
//  LoginUserView.swift
//  glowHabitTracker
//
//  Created by Kaitlin Wood on 10/6/24.
//

import SwiftUI

struct LoginUserView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Welcome Back!")
                .font(.title)
                .padding()
                        
            VStack {
                
                AppTextField(icon: "envelope.fill", placeholder: "Email", label: $email)
                    .padding(.top)
                
                AppTextField(icon: "lock.fill", placeholder: "Password", label: $password)
                    .padding(.top)
                
                Spacer()
            }
            .frame(height: 250)
            
            GradientButton(title: "Login", action: {}, isEnabled: true)


            Spacer()
        }
        .padding(.horizontal)
        .ignoresSafeArea(edges: .all)
        .background(.whitePrimary)
    }
}

#Preview {
    LoginUserView()
}
