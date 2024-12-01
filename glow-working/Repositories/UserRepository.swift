////
////  UserRepository.swift
////  glow-working
////
////  Created by Kaitlin Wood on 11/17/24.
////
//
//import Firebase
//import FirebaseFirestore
//import FirebaseAuth
//
//class UserRepository {
//    private let db = Firestore.firestore()
//
//    // Create or update user in Firestore
//    func createUser(user: User) async throws {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            throw NSError(domain: "UserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
//        }
//
//        try await db.collection("users").document(userId).setData(from: user)
//    }
//    
//    // Fetch user data
//    func getUser() async throws -> User? {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            throw NSError(domain: "UserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
//        }
//
//        let document = try await db.collection("users").document(userId).getDocument()
//        
//        if let data = document.data() {
//            let user = try Firestore.Decoder().decode(User.self, from: data)
//            return user
//        }
//        
//        return nil
//    }
//}
