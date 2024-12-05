//
//  AuthentificationViewModel.swift
//  glow-working
//
//  Created by Kaitlin Wood on 11/16/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// Enum to represent the authentication state of the user
enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

// Enum to represent the current flow (login or sign-up)
enum AuthenticationFlow {
    case login
    case signUp
}

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = "" // User's email
    @Published var password: String = "" // User's password
    @Published var confirmPassword: String = "" // User's password confirmation
    @Published var fullName: String = "" // User's full name
    
    @Published var flow: AuthenticationFlow = .login // Current flow (login or sign-up)
    
    @Published var isValid: Bool  = false // Flag to indicate if the input fields are valid
    @Published var authenticationState: AuthenticationState = .unauthenticated // Current authentication state
    @Published var user: User? // Authenticated user
    @Published var errorMessage: String = "" // Error message for authentication issues
    @Published var displayName: String = "" // User's display name
    @Published var hasCompletedOnboarding: Bool = false // Flag indicating onboarding status
    
    // Initializer to set up state handlers and bindings
    init() {
        registerAuthStateHandler()
        
        // Combine input fields to set `isValid` based on flow type
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    // Function to register an authentication state handler to listen for changes in user authentication
    func registerAuthStateHandler() {
           Auth.auth().addStateDidChangeListener { [weak self] auth, user in
               guard let self = self else { return }
               Task {
                   if let user = user {
                       // Check onboarding status when user signs in
                       let db = Firestore.firestore()
                       do {
                           let document = try await db.collection("users").document(user.uid).getDocument()
                           let hasCompletedOnboarding = document.data()?["hasCompletedOnboarding"] as? Bool ?? false
                           
                           DispatchQueue.main.async {
                               self.user = user
                               self.hasCompletedOnboarding = hasCompletedOnboarding
                               self.authenticationState = .authenticated
                               self.displayName = user.displayName ?? ""
                           }
                       } catch {
                           print("Error fetching user data: \(error)")
                           DispatchQueue.main.async {
                               self.authenticationState = .unauthenticated
                           }
                       }
                   } else {
                       // When there is no user signed in, reset relevant properties
                       DispatchQueue.main.async {
                           self.user = nil
                           self.hasCompletedOnboarding = false
                           self.authenticationState = .unauthenticated
                       }
                   }
               }
           }
       }
       
    // Function to mark onboarding as complete and update Firestore
       func completeOnboarding() async {
           guard let userId = user?.uid else { return }
           let db = Firestore.firestore()
           do {
               try await db.collection("users").document(userId).updateData([
                   "hasCompletedOnboarding": true
               ])
               DispatchQueue.main.async {
                   self.hasCompletedOnboarding = true
               }
           } catch {
               print("Error updating onboarding status: \(error)")
           }
       }
    
    // Function to toggle between login and sign-up flow
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    // Helper function for simulating a wait (used for testing)
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch { }
    }
    
    // Function to reset the view model's properties
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
    }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
    // Function to sign in with email and password
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            user = authResult.user
            print("User \(authResult.user.uid) signed in")
            
            displayName = user?.displayName ?? ""
            authenticationState = .authenticated
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    // Function to sign up with email, password, and full name
    func signUpWithEmailPassword(email: String, password: String, fullName: String) async -> Bool {
        authenticationState = .authenticating
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            user = authResult.user
            print("User \(authResult.user.uid) signed up")

            // Update the user's profile with their full name
            let changeRequest = user?.createProfileChangeRequest()
            changeRequest?.displayName = fullName
            try await changeRequest?.commitChanges()

            displayName = fullName
            authenticationState = .authenticated
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signOut() {
        authenticationState = .unauthenticated
    }
    
    func deleteAccount() async -> Bool {
        authenticationState = .unauthenticated
        return true
    }
}
