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
    @State private var login: Bool = false
    @State private var navigateToSignup: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Welcome Back!")
                    .font(.title)
                
                VStack(spacing: 0) {
                    
                    AppTextField(icon: "envelope.fill", placeholder: "Email", label: $email)
                        .padding(.top)

                    
                    AppTextField(icon: "lock.fill", placeholder: "Password", label: $password)
                        .padding(.top)
                    
                    Button(action: {
                        
                    }) {
                        Text("Forgot Password?")
                            .foregroundStyle(Color.gray)
                            .font(.caption.bold())
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                }
                
                GradientButton(title: "Login", action: {
                    login = true
                }, isEnabled: true)
                .padding(.top)
                

                
                Spacer()
                
                Button(action: {
                    navigateToSignup = true
                }) {
                    HStack(spacing: 5) {
                        Text("Don't have an account? ")
                            .bold()
                            .foregroundStyle(Color.gray1)
                        Text("Sign up")
                            .bold()
                            .foregroundStyle(Color.blue1)
                    }
                }
                .padding()
            }
            .padding()
            .ignoresSafeArea(edges: .all)
            .background(.whitePrimary)
            .toolbarVisibility(.hidden)
            .navigationDestination(isPresented: $login) {
                ContentView()
            }
            .navigationDestination(isPresented: $navigateToSignup) {
                RegisterNewUserView()
            }
        }
    }
}

#Preview {
    LoginUserView()
}
