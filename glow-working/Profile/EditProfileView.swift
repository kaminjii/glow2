import SwiftUI
import FirebaseAuth

// Main view for editing profile
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel // ViewModel to handle profile data
    @Environment(\.dismiss) var dismiss // Environment value to handle dismissing view for cancel
    @State private var showChangePasswordSheet = false // State to show/hide Change Password sheet
    @State private var showTwoFactorSheet = false // State to show/hide Two-Factor Authentication sheet
    
    var body: some View {
        NavigationStack { // Embeds view in NavigationStack
            ScrollView {  // Scroll enabled
                VStack(spacing: 24) { // Main vertical stack
                    profileImageSection // Profile image and name
                    
                    inputFields // Input fields for updating data
                    
                    Divider()
                        .padding(.vertical)
                    
                    securitySection // Buttons for password/2FA
                }
                .padding()
            }
            .background(Color.whitePrimary)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline) // Displays title inline
            .toolbar { // Adds toolbar items
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() } // Dismiss view on cancel
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { // Calls updateProfile
                        Task {
                            await viewModel.updateProfile()
                            dismiss()
                        }
                    }
                    .bold()
                }
            }
            .sheet(isPresented: $showChangePasswordSheet) { // Shows change password sheet when triggered
                ChangePasswordView(viewModel: viewModel)
            }
            .sheet(isPresented: $showTwoFactorSheet) { // Shows 2FA sheet when triggered
                TwoFactorView()
            }
        }
    }
    
    // Section displaying the profile image and name
    private var profileImageSection: some View {
        VStack(spacing: 16) {
            Image(viewModel.starImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .shadow(color: .blackShadow, radius: 10)
            
            Text(viewModel.fullName)
                .font(.title2).bold()
        }
    }
    
    // Section with input fields for name and email
    private var inputFields: some View {
        VStack(spacing: 20) {
            InputField( // Custom input field for name
                title: "Name",
                text: $viewModel.fullName,
                icon: "person.fill"
            )
            
            InputField( // Custom input field for email
                title: "Email",
                text: $viewModel.email,
                icon: "envelope.fill"
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        }
    }
    
    // Section with buttons for security settings (password/2FA)
    private var securitySection: some View {
        VStack(spacing: 16) {
            Button(action: { showChangePasswordSheet = true }) {
                SecurityButton(
                    title: "Change Password",
                    icon: "lock.fill"
                )
            }
            
            Button(action: { showTwoFactorSheet = true }) {
                SecurityButton(
                    title: "Two-Factor Authentication",
                    icon: "shield.fill",
                    subtitle: "Off"
                )
            }
        }
    }
}

// Custom input field view
struct InputField: View {
    let title: String // Field title
    @Binding var text: String // Binding text for modularity and updates
    let icon: String // Icon displayed based on field
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(.gray1)
                .font(.subheadline)
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.gray1)
                    .frame(width: 24)
                
                TextField(title, text: $text) // Textfield for user input
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.gray2)
            .cornerRadius(12)
        }
    }
}

// Custom button view for security actions
struct SecurityButton: View {
    let title: String
    let icon: String
    var subtitle: String? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.gray1)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(.black1)
                if let subtitle = subtitle { // Displays subtitle if available
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.gray1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray3)
        }
        .padding()
        .background(Color.gray2)
        .cornerRadius(12)
    }
}

// View for changing the password
struct ChangePasswordView: View {
    @ObservedObject var viewModel: ProfileViewModel // ViewModel to handle updating data
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the view
    @State private var currentPassword = "" // State for current password
    @State private var newPassword = "" // State for new password
    @State private var confirmPassword = "" // State for confirming new password
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Input fields for current, new, and confirm passwords
                AppTextField(icon: "lock.fill", placeholder: "Current Password", isSecure: true, label: $currentPassword)
                AppTextField(icon: "lock.fill", placeholder: "New Password", isSecure: true, label: $currentPassword)
                AppTextField(icon: "lock.fill", placeholder: "Comfirm New Password", isSecure: true, label: $currentPassword)
                
                Spacer()
                
            }
            .padding()
            .background(Color.whitePrimary)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Toolbar with cancel and done buttons
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { // Updates password and dismisses view
                        Task {
                            await viewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
                            dismiss()
                        }
                    }
                    .disabled(newPassword != confirmPassword || newPassword.isEmpty) // Disables button if input not valid
                }
            }
        }
    }
}

// View for 2FA
struct TwoFactorView: View {
    var body: some View {
        Text("Two Factor Authentication")
    }
}

#Preview {
    EditProfileView(viewModel: ProfileViewModel())
}
