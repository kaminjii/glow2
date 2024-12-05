//
//  UserManager.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

class UserManager: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var deleteError: String?
    @Published var reauthPassword = ""
    @Published var isProcessingDelete = false
    @Published var showReauthDialog = false
    
    private let db = Firestore.firestore()
    
    /// Loads user profile data from Firestore
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self,
                  let data = document?.data() else { return }
            
            DispatchQueue.main.async {
                self.fullName = data["fullName"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
            }
        }
    }
    
    /// Updates user profile information in Firestore
    func updateProfile(fullName: String, email: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "fullName": fullName,
            "email": email
        ]
        
        try await db.collection("users").document(userId).setData(data, merge: true)
    }
    
    /// Updates user password in Firebase Auth
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await user.reauthenticate(with: credential)
        try await user.updatePassword(to: newPassword)
    }
    
    /// Initiates the account deletion process
    func deleteAccount() {
        showReauthDialog = true
    }
    
    func resetDeleteAccountState() {
        deleteError = nil
        reauthPassword = ""
    }
    
    /// Confirms and executes account deletion after reauthorization
    func confirmDeleteAccount(password: String) async -> Bool {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            deleteError = "No user found"
            return false
        }
        
        isProcessingDelete = true
        defer { isProcessingDelete = false }
        
        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)
            
            // Delete user data
            let userDoc = db.collection("users").document(user.uid)
            
            // Delete subcollections
            let subcollections = ["dailyLogs", "goals", "achievements"]
            for collection in subcollections {
                let snapshot = try await userDoc.collection(collection).getDocuments()
                for document in snapshot.documents {
                    try await document.reference.delete()
                }
            }
            
            try await userDoc.delete()
            try await user.delete()
            
            return true
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.wrongPassword.rawValue:
                deleteError = "Incorrect password"
            case AuthErrorCode.tooManyRequests.rawValue:
                deleteError = "Too many attempts. Please try again later"
            default:
                deleteError = "Failed to delete account: \(error.localizedDescription)"
            }
            return false
        }
    }
}
