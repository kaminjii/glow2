//
//  EditProfileView.swift
//  glow-working
//
//  Created by Alfredo Ruiz on 10/24/24.
//

import SwiftUI

struct EditProfileView: View {
    @Binding var navigationPath: NavigationPath
    @State private var editType: EditType?
    
    var body: some View {
        VStack {
            Text("Edit Profile")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            // Name edit option
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray1)
                Text("Kaitlin Wood")
                    .foregroundColor(.gray1)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onTapGesture {
                editType = .name
                navigationPath.append(editType!)
            }
            .padding(.horizontal)
            
            // Email edit option
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray1)
                Text("kaitlin@email.com")
                    .foregroundColor(.gray1)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onTapGesture {
                editType = .email
                navigationPath.append(editType!)
            }
            .padding(.horizontal)
            
            // Password edit option
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray1)
                Text("Change Password")
                    .foregroundColor(.gray1)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onTapGesture {
                editType = .password
                navigationPath.append(editType!)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Sign out button
            Button(action: {
                // Add sign-out logic
            }) {
                Text("Sign out")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
            }
            .padding()
        }
        .padding(.top)
        .navigationDestination(for: EditType.self) { type in
            UpdateInfoView(editType: type)
        }
    }
}

#Preview {
    EditProfileView(navigationPath: .constant(NavigationPath()))
}

