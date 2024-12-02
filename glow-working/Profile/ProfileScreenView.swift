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
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        profileHeader
                        statsCard
                        achievementsSection
                        accountButtons
                    }
                    .padding(.horizontal)
                }
            }
        }
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
                Text(viewModel.userName)
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

class ProfileViewModel: ObservableObject {
    @Published var userName = ""
    @Published var email = ""
    @Published var showEditProfile = false
    @Published var showChangePassword = false
    @Published var achievements: [Achievement] = []
    @Published var recordedDays = 0
    @Published var streak = 0
    
    private let db = Firestore.firestore()
    
    var starImage: String {
        return "star3" // You can implement logic to determine star based on progress
    }
    
    var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalAchievements: Int {
        AchievementManager.achievements.count
    }
    
    init() {
        loadUserData()
        loadAchievements()
        calculateStats()
    }
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self,
                  let data = document?.data() else { return }
            
            DispatchQueue.main.async {
                self.userName = data["fullName"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
            }
        }
    }
    
    private func loadAchievements() {
        self.achievements = AchievementManager.achievements
        
        // Load unlocked status from Firestore
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("achievements")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let unlockedTitles = Set(documents.compactMap { $0["title"] as? String })
                
                DispatchQueue.main.async {
                    self?.achievements = self?.achievements.map { achievement in
                        var updatedAchievement = achievement
                        updatedAchievement.isUnlocked = unlockedTitles.contains(achievement.title)
                        return updatedAchievement
                    } ?? []
                }
            }
    }
    
    private func calculateStats() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Calculate recorded days
        db.collection("users").document(userId).collection("dailyLogs")
            .getDocuments { [weak self] snapshot, error in
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.recordedDays = count
                }
            }
        
        // Calculate streak
        calculateStreak()
    }
    
    private func calculateStreak() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        db.collection("users").document(userId).collection("dailyLogs")
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                var currentStreak = 0
                var currentDate = today
                
                for document in documents {
                    let logDate = (document["date"] as? Timestamp)?.dateValue() ?? Date()
                    let normalizedLogDate = calendar.startOfDay(for: logDate)
                    
                    if calendar.isDate(normalizedLogDate, inSameDayAs: currentDate) {
                        currentStreak += 1
                        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    } else {
                        break
                    }
                }
                
                DispatchQueue.main.async {
                    self?.streak = currentStreak
                }
            }
    }
    
    func updateProfile() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "userName": userName,
            "email": email
        ]
        
        do {
            try await db.collection("users").document(userId).setData(data, merge: true)
        } catch {
            print("Failed to update profile: \(error.localizedDescription)")
        }
    }

    func updatePassword(currentPassword: String, newPassword: String) async {
        guard let user = Auth.auth().currentUser else { return }
        
        // Reauthenticate user
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        do {
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        } catch {
            print("Error updating password: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Delete Firestore data
        let batch = db.batch()
        let userDoc = db.collection("users").document(user.uid)
        
        // Delete user document and subcollections
        userDoc.delete()
        
        // Delete Firebase Auth account
        user.delete { error in
            if let error = error {
                print("Error deleting account: \(error)")
            }
        }
    }
}

struct Achievement: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    var isUnlocked: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

struct UserAchievement: Codable {
    let title: String
    let description: String
    let dateEarned: Timestamp
    let type: String
}

struct AchievementManager {
    static let achievements = [
        // Streak Achievements
        Achievement(title: "First Steps", description: "Log in for 3 days in a row"),
        Achievement(title: "Momentum Builder", description: "Maintain a 7-day streak"),
        Achievement(title: "Habit Master", description: "Maintain a 30-day streak"),
        Achievement(title: "Dedicated User", description: "Maintain a 100-day streak"),
        
        // Completion Achievements
        Achievement(title: "Perfect Day", description: "Complete all goals in one day"),
        Achievement(title: "Perfect Week", description: "Complete all goals for 7 days"),
        Achievement(title: "Goal Crusher", description: "Complete 50 total goals"),
        Achievement(title: "Century Club", description: "Complete 100 total goals"),
        
        // Progress Achievements
        Achievement(title: "Getting Started", description: "Track your first goal"),
        Achievement(title: "Progress Pioneer", description: "Reach 50% completion on all goals"),
        Achievement(title: "Consistency King", description: "Maintain 80% completion for a week"),
        
        // Time-based Achievements
        Achievement(title: "First Month", description: "Use Glow for 30 days"),
        Achievement(title: "Quarterly Success", description: "Use Glow for 90 days"),
        Achievement(title: "Half Year Hero", description: "Use Glow for 180 days"),
        Achievement(title: "Year of Growth", description: "Use Glow for 365 days"),
        
        // Special Achievements
        Achievement(title: "Early Bird", description: "Log progress before 8 AM"),
        Achievement(title: "Night Owl", description: "Log progress after 10 PM"),
        Achievement(title: "Weekend Warrior", description: "Complete all goals on weekends for a month"),
        Achievement(title: "Comeback King", description: "Resume after a 7-day break"),
        Achievement(title: "Share & Grow", description: "Share your progress on social media")
    ]
}

#Preview {
    ProfileScreenView(selectedTab: .constant(4))
}

