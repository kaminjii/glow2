import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterNewUserView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    @State var fullName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State private var isAuthenticating: Bool = false
    @State private var signUpClicked: Bool = false
    @State private var navigateToLogin: Bool = false
    
    private func signUpWithEmailPassword() {
        guard password == confirmPassword else {
            return
        }

        guard password.count >= 6 else {
            return
        }

        isAuthenticating = true
        Task {
            do {
                // First create the auth user
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = result.user.uid
                
                // Create a reference to the users collection
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(uid)
                
                // Create user data
                let userData: [String: Any] = [
                    "fullName": fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
                    "createdAt": FieldValue.serverTimestamp(),
                    "uid": uid
                ]
                
                // Try to write to Firestore with explicit error handling
                do {
                    // Create the user document
                    try await userRef.setData(userData)
                    
                    // Create an empty document in the goals collection to initialize it
                    let goalsRef = userRef.collection("goals")
                    let emptyGoalDoc = goalsRef.document()
                    try await emptyGoalDoc.setData([:])
                    
                    // Do the same for dailyLogs collection
                    let dailyLogsRef = userRef.collection("dailyLogs")
                    let emptyLogDoc = dailyLogsRef.document()
                    try await emptyLogDoc.setData([:])
                    try await emptyLogDoc.delete()
                    
                    print("Successfully created user document and collections in Firestore")
                    signUpClicked = true
                } catch let firestoreError {
                    print("Firestore error: \(firestoreError.localizedDescription)")
                    // Since auth was successful but Firestore failed, you might want to delete the auth user
                    try? await result.user.delete()
                    throw firestoreError
                }
            } catch {
                print("Error during sign up: \(error)")
            }
            
            isAuthenticating = false
        }
    }


    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Sign Up")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(.title)
                
                VStack {
                    AppTextField(icon: "person.fill", placeholder: "Full Name", label: $fullName)
                        .padding(.top)
                    
                    AppTextField(icon: "envelope.fill", placeholder: "Email", label: $email)
                        .padding(.top)
                    
                    AppTextField(icon: "lock.fill", placeholder: "Password", isSecure: true, label: $password)
                        .padding(.top)
                    
                    AppTextField(icon: "lock.fill", placeholder: "Confirm Password", isSecure: true, label: $confirmPassword)
                        .padding(.top)
                    
                }
                
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .padding(.top)
                } else {
                    GradientButton(
                        title: "Sign Up",
                        action: signUpWithEmailPassword,
                        isEnabled: !isAuthenticating
                    )
                    .padding(.top)
                }
                
                Spacer()
                
                Button(action: {
                    navigateToLogin = true
                }) {
                    HStack(spacing: 5) {
                        Text("Already have an account? ")
                            .bold()
                            .foregroundStyle(Color.gray1)
                        Text("Login")
                            .bold()
                            .foregroundStyle(Color.blue1)
                    }
                }
                .padding()
            }
            .padding()
            .ignoresSafeArea(edges: .all)
            .background(.whitePrimary)
            .navigationDestination(isPresented: $signUpClicked) {
                SelectTemplateGoalsView()
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginUserView()
            }
            .toolbarVisibility(.hidden)
            
        }
    }
}

#Preview {
    RegisterNewUserView()
}
