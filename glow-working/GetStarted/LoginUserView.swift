//
//  LoginUserView.swift
//  glowHabitTracker
//
//  Created by Kaitlin Wood on 10/6/24.
//

import SwiftUI
import FirebaseAuth

struct LoginUserView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State private var navigateToSignup: Bool = false
    @State private var isAuthenticating: Bool = false
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    private func signInWithEmailPassword() {
        isAuthenticating = true
        Task {
            viewModel.email = email
            viewModel.password = password
            
            if await viewModel.signInWithEmailPassword() {
                print("Login successful")
            } else {
                print("Login failed: \(viewModel.errorMessage)")
            }
            isAuthenticating = false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Welcome Back!")
                    .font(.title)
                
                VStack(spacing: 0) {
                    AppTextField(icon: "envelope.fill", placeholder: "Email", label: $email)
                        .padding(.top)
                    
                    AppTextField(icon: "lock.fill", placeholder: "Password", isSecure: true, label: $password)
                        .padding(.top)
                    
                    Button(action: {
                        // Forgot password action
                    }) {
                        Text("Forgot Password?")
                            .foregroundStyle(Color.gray)
                            .font(.caption.bold())
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .padding(.top)
                } else {
                    GradientButton(
                        title: "Login",
                        action: signInWithEmailPassword,
                        isEnabled: !isAuthenticating
                    )
                    .padding(.top)
                }
                
                Spacer()
                
                Button(action: {
                    navigateToSignup = true
                }) {
                    HStack(spacing: 5) {
                        Text("Don't have an account yet? ")
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
            .navigationDestination(isPresented: $navigateToSignup) {
                RegisterNewUserView()
            }
        }
    }
}

#Preview {
    LoginUserView()
}
