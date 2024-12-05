//
//  LoginUserView.swift
//  glowHabitTracker
//
//  Created by Kaitlin Wood on 10/6/24.
//

import SwiftUI
import FirebaseAuth

// View for user login, providing fields for email and password authentication.
struct LoginUserView: View {
    @State var email: String = "" // State for storing the user's email input.
    @State var password: String = "" // State for storing the user's password input.
    @State private var navigateToSignup: Bool = false // State to control navigation to the sign-up screen.
    @State private var isAuthenticating: Bool = false // State to show a loading indicator during authentication.
    @State private var showError: Bool = false // State to manage showing error alerts.
    @State private var errorMessage: String = "" // State for holding the error message to display.
    @State private var animate = false // State for controlling the animation of the UI elements.
    @State private var navigateToForgotPassword = false // State to control navigation to the forgot password screen.
    
    @EnvironmentObject var viewModel: AuthenticationViewModel // Environment object for handling authentication logic.
    
    // Function for signing in the user with email and password.
    private func signInWithEmailPassword() {
        // Validate email input.
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        // Validate password input.
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            showError = true
            return
        }
        
        // Ensure the email format is valid.
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isAuthenticating = true // Set authentication state to true to show loading indicator.
        
        // Perform asynchronous sign-in operation.
        Task {
            viewModel.email = email
            viewModel.password = password
            
            if await viewModel.signInWithEmailPassword() {
                print("Login successful")
            } else {
                // Handle various authentication errors and display appropriate messages.
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
    
// MARK: - Main View Structure
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background animation
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
                                .scaleEffect(animate ? 1 : 0.5) // Animates logo scaling effect.

                            VStack(spacing: 8) {
                                Text("Welcome Back!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .opacity(animate ? 1 : 0) // Animates text opacity.
                                    .offset(y: animate ? 0 : 20) // Animates text vertical position.

                                Text("Sign in to continue")
                                    .font(.subheadline)
                                    .foregroundColor(.gray1)
                                    .opacity(animate ? 1 : 0) // Animates text opacity.
                                    .offset(y: animate ? 0 : 20) // Animates text vertical position.
                            }
                        }
                        .padding(.top, 60)
                        
                        // Input fields for email and password with animated appearance.
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
                            
                            // Forgot password link.
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
                        
                        // Sign up link for users who do not have an account.
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
                RegisterInfoView() // Navigation destination for sign-up.
            }
            .navigationDestination(isPresented: $navigateToForgotPassword) {
                ForgotPasswordView() // Navigation destination for password reset.
            }
            // Alert for displaying error messages when sign-in fails.
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
