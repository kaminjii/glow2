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
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var animate = false
    @State private var navigateToForgotPassword = false
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    private func signInWithEmailPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            showError = true
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isAuthenticating = true
        Task {
            viewModel.email = email
            viewModel.password = password
            
            if await viewModel.signInWithEmailPassword() {
                print("Login successful")
            } else {
                let authError = viewModel.errorMessage.lowercased()
                if authError.contains("no user record") {
                    errorMessage = "No account found with this email"
                } else if authError.contains("wrong password") {
                    errorMessage = "Incorrect password"
                } else if authError.contains("invalid email") {
                    errorMessage = "Invalid email format"
                } else if authError.contains("network error") {
                    errorMessage = "Network error. Please check your internet connection"
                } else {
                    errorMessage = "Login failed. Please try again"
                }
                showError = true
            }
            isAuthenticating = false
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                AnimatedStarField()
  
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Logo and Welcome section
                        VStack(spacing: 16) {
                            Image("glowLogoYellow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .scaleEffect(animate ? 1 : 0.5)
                            
                            VStack(spacing: 8) {
                                Text("Welcome Back!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .opacity(animate ? 1 : 0)
                                    .offset(y: animate ? 0 : 20)
                                
                                Text("Sign in to continue")
                                    .font(.subheadline)
                                    .foregroundColor(.gray1)
                                    .opacity(animate ? 1 : 0)
                                    .offset(y: animate ? 0 : 20)
                            }
                        }
                        .padding(.top, 60)
                        
                        // Input Fields
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .foregroundStyle(.gray1)
                                    .font(.subheadline)
                                AppTextField(
                                    icon: "envelope.fill",
                                    placeholder: "Enter your email",
                                    label: $email
                                )
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                            }
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 20)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .foregroundStyle(.gray1)
                                    .font(.subheadline)
                                AppTextField(
                                    icon: "lock.fill",
                                    placeholder: "Enter your password",
                                    isSecure: true,
                                    label: $password
                                )
                            }
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 20)
                            
                            Button(action: {
                                navigateToForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .foregroundStyle(Color.gray)
                                    .font(.caption.bold())
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .opacity(animate ? 1 : 0)
                        }
                        .padding(.horizontal)
                        
                        // Login Button
                        VStack(spacing: 16) {
                            if isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(1.2)
                            } else {
                                GradientButton(
                                    title: "Sign In",
                                    action: signInWithEmailPassword,
                                    isEnabled: !email.isEmpty && !password.isEmpty
                                )
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 30)
                        
                        // Sign Up Button
                        Button(action: {
                            navigateToSignup = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundStyle(Color.gray1)
                                Text("Sign up")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.blue1)
                            }
                            .font(.subheadline)
                        }
                        .opacity(animate ? 1 : 0)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSignup) {
                RegisterInfoView()
            }
            .navigationDestination(isPresented: $navigateToForgotPassword) {
                ForgotPasswordView()
            }
            .alert("Sign In Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                withAnimation(.spring(duration: 1.0)) {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    LoginUserView()
        .environmentObject(AuthenticationViewModel())
}
