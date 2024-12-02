import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showChangePasswordSheet = false
    @State private var showTwoFactorSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileImageSection
                    
                    inputFields
                    
                    Divider()
                        .padding(.vertical)
                    
                    securitySection
                }
                .padding()
            }
            .background(Color.whitePrimary)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            await viewModel.updateProfile()
                            dismiss()
                        }
                    }
                    .bold()
                }
            }
            .sheet(isPresented: $showChangePasswordSheet) {
                ChangePasswordView(viewModel: viewModel)
            }
            .sheet(isPresented: $showTwoFactorSheet) {
                TwoFactorView()
            }
        }
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 16) {
            Image(viewModel.starImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .shadow(color: .blackShadow, radius: 10)
            
            Text(viewModel.userName)
                .font(.title2).bold()
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Name",
                text: $viewModel.userName,
                icon: "person.fill"
            )
            
            InputField(
                title: "Email",
                text: $viewModel.email,
                icon: "envelope.fill"
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        }
    }
    
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

struct InputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(.gray1)
                .font(.subheadline)
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.gray1)
                    .frame(width: 24)
                
                TextField(title, text: $text)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.gray2)
            .cornerRadius(12)
        }
    }
}

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
                if let subtitle = subtitle {
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

struct ChangePasswordView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AppTextField(icon: "lock.fill", placeholder: "Current Password", isSecure: true, label: $currentPassword)
                AppTextField(icon: "lock.fill", placeholder: "New Password", isSecure: true, label: $currentPassword)
                AppTextField(icon: "lock.fill", placeholder: "Comfirm New Password", isSecure: true, label: $currentPassword)
                
                Spacer()
                
            }
            .padding()
            .background(Color.whitePrimary)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            await viewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
                            dismiss()
                        }
                    }
                    .disabled(newPassword != confirmPassword || newPassword.isEmpty)
                }
            }
        }
    }
}

struct TwoFactorView: View {
    var body: some View {
        Text("Two Factor Authentication")
    }
}

#Preview {
    EditProfileView(viewModel: ProfileViewModel())
}
