//
//  RegisterPasswordView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/1/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct RegisterPasswordView: View {
    let fullName: String
    let email: String
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAuthenticating: Bool = false
    @State private var signUpClicked: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var animate = false
    
    private func validateAndSignUp() {
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        signUpWithEmailPassword()
    }
    
    private func signUpWithEmailPassword() {
        isAuthenticating = true
        Task {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = result.user.uid
                
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(uid)
                
                let userData: [String: Any] = [
                    "fullName": fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                    "createdAt": FieldValue.serverTimestamp(),
                    "uid": uid,
                    "hasCompletedOnboarding": false
                ]
                
                do {
                    try await userRef.setData(userData)
                    
                    let goalsRef = userRef.collection("goals")
                    let emptyGoalDoc = goalsRef.document()
                    try await emptyGoalDoc.setData([:])
                    
                    let dailyLogsRef = userRef.collection("dailyLogs")
                    let emptyLogDoc = dailyLogsRef.document()
                    try await emptyLogDoc.setData([:])
                    try await emptyLogDoc.delete()
                    
                    signUpClicked = true
                } catch {
                    errorMessage = "Error creating user profile. Please try again."
                    showError = true
                    try? await result.user.delete()
                }
            } catch let error as NSError {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "This email is already registered"
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email format"
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "Password is too weak"
                default:
                    errorMessage = "Sign up failed. Please try again."
                }
                showError = true
            }
            
            isAuthenticating = false
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedStarField()
            
                VStack(spacing: 32) {
                    // Logo and Welcome section
                    VStack(spacing: 16) {
                        Image("glowLogoYellow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .scaleEffect(animate ? 1 : 0.5)
                        
                        VStack(spacing: 8) {
                            Text("Create Password")
                                .font(.title)
                                .fontWeight(.bold)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                            
                            Text("Choose a secure password")
                                .font(.subheadline)
                                .foregroundColor(.gray1)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                        }
                    }
                    .padding(.top, 20) // Reduced top padding to account for navigation bar
                    
                    // Password Fields
                    VStack(spacing: 20) {
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .foregroundStyle(.gray1)
                                .font(.subheadline)
                            AppTextField(
                                icon: "lock.fill",
                                placeholder: "Confirm your password",
                                isSecure: true,
                                label: $confirmPassword
                            )
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Button
                    if isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.2)
                    } else {
                        GradientButton(
                            title: "Create Account",
                            action: validateAndSignUp,
                            isEnabled: !password.isEmpty && !confirmPassword.isEmpty
                        )
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $signUpClicked) {
            SelectTemplateGoalsView()
        }
        .alert("Sign Up Failed", isPresented: $showError) {
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
#Preview {
    RegisterPasswordView(fullName: "", email: "")
}
