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
    // Properties passed from the previous view (RegisterInfoView)
    let fullName: String
    let email: String
    
    // Environment object for authentication management
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss  // Used to dismiss the view when necessary
    
    // State properties for input fields and UI states
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAuthenticating: Bool = false // Indicates if the sign-up process is ongoing
    @State private var signUpClicked: Bool = false    // Flag to navigate to the next screen after sign-up
    @State private var showError: Bool = false        // Flag to show an error alert
    @State private var errorMessage: String = ""      // Message for the error alert
    @State private var animate = false                // Flag for animation control
    
    // Function to validate input and proceed with sign-up if valid
    private func validateAndSignUp() {
        // Check if password is entered
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            showError = true
            return
        }
        
        // Ensure the password meets the minimum length requirement
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            showError = true
            return
        }
        
        // Check that the password and confirm password match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        // Proceed with the sign-up process if all validations pass
        signUpWithEmailPassword()
    }
    
    // Function to handle user sign-up using Firebase authentication
    private func signUpWithEmailPassword() {
        isAuthenticating = true  // Set authentication state to true
        
        Task {
            do {
                // Attempt to create a new user with the provided email and password
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = result.user.uid
                
                // Reference to Firestore database
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(uid)
                
                // Data to store in Firestore for the new user
                let userData: [String: Any] = [
                    "fullName": fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                    "createdAt": FieldValue.serverTimestamp(),
                    "uid": uid,
                    "hasCompletedOnboarding": false
                ]
                
                // Save user data to Firestore
                do {
                    try await userRef.setData(userData)
                    
                    // Create default goal and daily log documents for the user
                    let goalsRef = userRef.collection("goals")
                    let emptyGoalDoc = goalsRef.document()
                    try await emptyGoalDoc.setData([:])
                    
                    let dailyLogsRef = userRef.collection("dailyLogs")
                    let emptyLogDoc = dailyLogsRef.document()
                    try await emptyLogDoc.setData([:])
                    try await emptyLogDoc.delete()  // Delete the empty log after creation
                    
                    // Set the flag to navigate to the next screen after sign-up
                    signUpClicked = true
                } catch {
                    // Handle errors during user data creation
                    errorMessage = "Error creating user profile. Please try again."
                    showError = true
                    try? await result.user.delete()  // Delete user if profile creation fails
                }
            } catch let error as NSError {
                // Handle specific Firebase authentication errors
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
            
            // Reset the authentication state after processing
            isAuthenticating = false
        }
    }
    
    var body: some View {
        ZStack {
            // Background animation (star field)
            AnimatedStarField()
            
            // Main content layout
            VStack(spacing: 32) {
                // Logo and welcome section
                VStack(spacing: 16) {
                    Image("glowLogoYellow")  // App logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .scaleEffect(animate ? 1 : 0.5)  // Animation for the logo
                    
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
                
                // Password input fields
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
                
                // Sign-up button or progress indicator based on authentication state
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(1.2)  // Larger scale for better visibility
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
        .navigationBarTitleDisplayMode(.inline)  // Display mode for the navigation bar
        .toolbarBackground(.hidden, for: .navigationBar)  // Hide the navigation bar background
        .navigationDestination(isPresented: $signUpClicked) {
            SelectTemplateGoalsView()  // Navigate to the next screen after successful sign-up
        }
        .alert("Sign Up Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)  // Display error message in the alert
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0)) {
                animate = true  // Trigger animation when the view appears
            }
        }
    }
}

#Preview {
    RegisterPasswordView(fullName: "", email: "")
}
