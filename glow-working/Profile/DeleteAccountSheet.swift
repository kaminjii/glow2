//
//  DeleteAccountSheet.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import SwiftUI

struct DeleteAccountSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 100, height: 100)
                            )
                        
                        Text("Confirm Account Deletion")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.black1)
                        
                        Text("Please enter your password to permanently delete your account and all associated data.")
                            .font(.subheadline)
                            .foregroundStyle(.gray1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Password Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundStyle(.gray1)
                        
                        AppTextField(
                            icon: "lock",
                            placeholder: "Enter your password",
                            isSecure: true,
                            label: $viewModel.reauthPassword
                        )
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if let error = viewModel.deleteError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                if await viewModel.confirmDeleteAccount(password: viewModel.reauthPassword) {
                                    isPresented = false
                                    authViewModel.signOut()
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isProcessingDelete {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Delete Account")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                viewModel.reauthPassword.isEmpty || viewModel.isProcessingDelete
                                ? Color.red.opacity(0.3)
                                : Color.red
                            )
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.reauthPassword.isEmpty || viewModel.isProcessingDelete)
                        
                        Button {
                            isPresented = false
                            viewModel.resetDeleteAccountState()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray2)
                                .foregroundStyle(.black1)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .padding(.top, 40)
            }
        }
        .interactiveDismissDisabled(viewModel.isProcessingDelete)
    }
}
