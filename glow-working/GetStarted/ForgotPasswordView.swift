//
//  ForgotPasswordView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/1/24.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var animate = false
    
    private func resetPassword() {
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
        
        isLoading = true
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                showSuccess = true
            } catch let error as NSError {
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
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    }
                    .padding(.horizontal)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    
                    // Reset Button
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.2)
                    } else {
                        GradientButton(
                            title: "Send Reset Link",
                            action: resetPassword,
                            isEnabled: !email.isEmpty
                        )
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
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
                dismiss()
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
