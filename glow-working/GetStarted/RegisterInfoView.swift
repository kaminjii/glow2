import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterInfoView: View {
    @State var fullName: String = ""
    @State var email: String = ""
    @State private var navigateToPassword = false
    @State private var navigateToLogin: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var animate = false
    
    private func validateAndContinue() {
        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your full name"
            showError = true
            return
        }
        
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
        
        navigateToPassword = true
    }
    
    var body: some View {
        NavigationStack {
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
                                Text("Create Account")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .opacity(animate ? 1 : 0)
                                    .offset(y: animate ? 0 : 20)
                                
                                Text("First, tell us about yourself")
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
                                Text("Full Name")
                                    .foregroundStyle(.gray1)
                                    .font(.subheadline)
                                AppTextField(
                                    icon: "person.fill",
                                    placeholder: "Enter your full name",
                                    label: $fullName
                                )
                            }
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 20)
                            
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
                        }
                        .padding(.horizontal)
                        
                        // Continue Button
                        GradientButton(
                            title: "Continue",
                            action: validateAndContinue,
                            isEnabled: !fullName.isEmpty && !email.isEmpty
                        )
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                        
                        Spacer(minLength: 30)
                        
                        // Login Button
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .foregroundStyle(Color.gray1)
                                Text("Login")
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
            .navigationDestination(isPresented: $navigateToPassword) {
                RegisterPasswordView(fullName: fullName, email: email)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginUserView()
            }
            .alert("Invalid Information", isPresented: $showError) {
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
    RegisterInfoView()
        .environmentObject(AuthenticationViewModel())
}
