//
//  ProfileScreenView.swift
//  glow-working
//
//  Created by Alfredo Ruiz on 10/24/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum EditType {
    case name, email, password
}

struct ProfileScreenView: View {
    @Binding var selectedTab: Int
    @State private var showActionSheet = false
    @State private var showDeleteConfirmation = false
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
                
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    profileHeader
                    statsCard
                    achievementsSection
                    accountButtons
                }
                .padding(.horizontal)
            }
            .padding(.top, 1)
        }
        .background(Color.whitePrimary).edgesIgnoringSafeArea(.all)
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { viewModel.deleteAccount() }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 24) {
            Image(viewModel.starImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .shadow(color: .blackShadow, radius: 10)
            
            VStack(spacing: 8) {
                Text(viewModel.fullName)
                    .font(.title).bold()
                    .foregroundStyle(.black1)
                
                Button(action: { viewModel.showEditProfile = true }) {
                    Label("Edit Profile", systemImage: "pencil")
                        .font(.subheadline)
                        .foregroundStyle(.blue1)
                }
            }
        }
        .padding(.top, 40)
        .sheet(isPresented: $viewModel.showEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
    }
    
    private var statsCard: some View {
        HStack {
            StatView(
                icon: "pencil",
                title: "Recorded Days",
                value: "\(viewModel.recordedDays)"
            )
            
            Divider()
                .frame(height: 60)
                .background(Color.white.opacity(0.5))
            
            StatView(
                icon: "flame.fill",
                title: "Current Streak",
                value: "\(viewModel.streak) Days"
            )
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blueGradientStart, .blueGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .blackShadow, radius: 15)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.title2).bold()
                    .foregroundStyle(.black1)
                Spacer()
                Text("\(viewModel.unlockedAchievements) / \(viewModel.totalAchievements)")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
    
    private var accountButtons: some View {
        VStack(spacing: 16) {
            ActionButton(
                title: "Sign Out",
                icon: "rectangle.portrait.and.arrow.right",
                style: .secondary
            ) {
                authViewModel.signOut()
            }
            
            ActionButton(
                title: "Delete Account",
                icon: "trash",
                style: .destructive
            ) {
                showDeleteConfirmation = true
            }
        }
        .padding(.vertical)
    }
}

struct StatView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                Text(value)
                    .font(.title3).bold()
                    .foregroundStyle(.white)
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            GradientIcon(iconName: "trophy.fill")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(.black1)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .blackShadow, radius: 10, y: 5)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .black1
            case .destructive: return .red
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .blue1
            case .secondary: return .gray2
            case .destructive: return .red.opacity(0.1)
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .cornerRadius(16)
        }
    }
}


#Preview {
    ProfileScreenView(selectedTab: .constant(4))
}

