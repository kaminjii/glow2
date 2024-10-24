//
//  UpdateInfoView.swift
//  glow-working
//
//  Created by Alfredo Ruiz on 10/24/24.
//

import SwiftUI

struct UpdateInfoView: View {
    let editType: EditType
    
    var body: some View {
        VStack (spacing: 20) {
            if editType == .name {
                Text("Change Name")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray1)
                    TextField("First Name", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray1)
                    TextField("Last Name", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
            } else if editType == .email {
                Text("Update Email")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray1)
                    TextField("Current Email", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray1)
                    TextField("New Email", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray1)
                    TextField("Confirm New Email", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
            } else if editType == .password {
                Text("Change Password")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray1)
                    SecureField("Current Password", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray1)
                    SecureField("New Password", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray1)
                    SecureField("Confirm New Password", text: .constant(""))
                        .foregroundColor(.gray1)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Save and Cancel buttons
            HStack {
                Button(action: {
                    // Save changes
                }) {
                    Text("Save")
                        .padding()
                        .frame(minWidth: 169, maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(99)
                }
                .padding()
                
                Button(action: {
                    // Cancel changes
                }) {
                    Text("Cancel")
                        .padding()
                        .frame(minWidth: 169, maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(99)
                }
                .padding()
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

#Preview {
    UpdateInfoView(editType: .name)
}

