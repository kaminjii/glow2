//
//  ForgotPasswordView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/1/24.
//

import SwiftUI
import FirebaseAuth

// A view that for password reset
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss  // Used to dismiss the view programmatically.
    @State private var email: String = ""  // State to hold the email entered by the user.
    @State private var isLoading: Bool = false  // State to track the loading status when sending a reset request.
    @State private var showError: Bool = false  // State to control the display of the error alert.
    @State private var errorMessage: String = ""  // State to hold the error message for the alert.
    @State private var showSuccess: Bool = false  // State to control the display of the success alert.
    @State private var animate = false  // State to control animations for UI elements.
    
    private func resetPassword() {
        // Validate the email input.
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isLoading = true // Set loading to true when starting the password reset process.
        Task {
            do {
                // Attempt to send the password reset email.
                try await Auth.auth().sendPasswordReset(withEmail: email)
                showSuccess = true
            } catch let error as NSError {
                // Handle different error cases.
                switch error.code {
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email format"
                case AuthErrorCode.userNotFound.rawValue:
                    errorMessage = "No account found with this email"
                default:
                    errorMessage = "Failed to send reset email. Please try again"
                }
                showError = true
            }
            isLoading = false
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedStarField()
            
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
                            Text("Reset Password")
                                .font(.title)
                                .fontWeight(.bold)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                            
                            Text("Enter your email to receive reset instructions")
                                .font(.subheadline)
                                .foregroundColor(.gray1)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Email Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .foregroundStyle(.gray1)
                            .font(.subheadline)
                        AppTextField(
                            icon: "envelope.fill",
                            placeholder: "Enter your email",
                            label: $email
                        )
                        .textInputAutocapitalization(.never)  // Disable auto-capitalization for email input.
                        .keyboardType(.emailAddress)  // Set the keyboard type to email.
                        .autocorrectionDisabled()  // Disable autocorrection for email input.
                    }
                    .padding(.horizontal)
                    .opacity(animate ? 1 : 0)  // Animate the opacity of the email input.
                    .offset(y: animate ? 0 : 20)  // Animate the offset of the email input.
                    
                    // Reset Button or Loading Indicator.
                    if isLoading {
                        // Display a loading indicator while processing.
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.2)
                    } else {
                        // Display the reset button when not loading.
                        GradientButton(
                            title: "Send Reset Link",
                            action: resetPassword,
                            isEnabled: !email.isEmpty  // Enable the button only if the email field is not empty.
                        )
                        .opacity(animate ? 1 : 0)  // Animate the opacity of the button.
                        .offset(y: animate ? 0 : 20)  // Animate the offset of the button.
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert("Reset Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Reset Link Sent", isPresented: $showSuccess) {
            Button("OK") {
                dismiss() // Dismiss the view when the user acknowledges the success alert.
            }
        } message: {
            Text("Please check your email for instructions to reset your password.")
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0)) {
                animate = true
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
