import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// View for the registration step where users input their name and email
struct RegisterInfoView: View {
    // State variables for user input and navigation
    @State var fullName: String = ""
    @State var email: String = ""
    @State private var navigateToPassword = false  // Controls navigation to password input view
    @State private var navigateToLogin: Bool = false  // Controls navigation to login view
    @State private var showError: Bool = false  // Controls displaying error alerts
    @State private var errorMessage: String = ""  // Stores the error message to display
    @State private var animate = false  // Controls animation effects
    
    // Function to validate user input and proceed to the next screen
    private func validateAndContinue() {
        // Check for empty full name
        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your full name"
            showError = true
            return
        }
        
        // Check for empty email
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        // Check if the email format is valid
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        // Navigate to the password screen if validation passes
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
                                .scaleEffect(animate ? 1 : 0.5)  // Animated logo scaling

                            VStack(spacing: 8) {
                                Text("Create Account")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .opacity(animate ? 1 : 0)  // Fade-in effect
                                    .offset(y: animate ? 0 : 20)  // Slide-in effect

                                Text("First, tell us about yourself")
                                    .font(.subheadline)
                                    .foregroundColor(.gray1)
                                    .opacity(animate ? 1 : 0)  // Fade-in effect
                                    .offset(y: animate ? 0 : 20)  // Slide-in effect
                            }
                        }
                        .padding(.top, 60)
                        
                        // Input fields for full name and email
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
                            .opacity(animate ? 1 : 0)  // Fade-in effect
                            .offset(y: animate ? 0 : 20)  // Slide-in effect
                            
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
                            .opacity(animate ? 1 : 0)  // Fade-in effect
                            .offset(y: animate ? 0 : 20)  // Slide-in effect
                        }
                        .padding(.horizontal)
                        
                        // Continue button for navigation
                        GradientButton(
                            title: "Continue",
                            action: validateAndContinue,
                            isEnabled: !fullName.isEmpty && !email.isEmpty
                        )
                        .opacity(animate ? 1 : 0)  // Fade-in effect
                        .offset(y: animate ? 0 : 20)  // Slide-in effect
                        
                        Spacer(minLength: 30)
                        
                        // Button to navigate to login view
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
                        .opacity(animate ? 1 : 0)  // Fade-in effect
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)  // Hide the navigation bar for this view
            .navigationDestination(isPresented: $navigateToPassword) {
                // Navigate to password registration view
                RegisterPasswordView(fullName: fullName, email: email)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                // Navigate to login view
                LoginUserView()
            }
            .alert("Invalid Information", isPresented: $showError) {
                // Alert for invalid information
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Trigger animation when the view appears
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
