//
//  ProfileViewModel.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/2/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var showEditProfile = false
    @Published var showChangePassword = false
    @Published var achievements: [Achievement] = []
    @Published var recordedDays = 0
    @Published var streak = 0
    
    private let db = Firestore.firestore()
    
    var starImage: String {
        return "star3"
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
        checkAndUpdateAchievements()
    }
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self,
                  let data = document?.data() else { return }
            
            DispatchQueue.main.async {
                self.fullName = data["fullName"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
            }
        }
    }
    
    func loadAchievements() {
        self.achievements = AchievementManager.achievements
        
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
            "fullName": fullName,
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
    
    // MARK: - Achievement Logic
    
    func refreshAchievements() {
        checkAndUpdateAchievements()
    }
    
    private func checkAndUpdateAchievements() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        let achievementsCollection = db.collection("users").document(userId).collection("achievements")
        
        db.collection("users").document(userId).collection("dailyLogs")
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                
                let logs = documents.compactMap { try? $0.data(as: DailyLog.self) }
                
                self.checkStreakAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkCompletionAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkTimeBasedAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkSpecialAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                
                batch.commit { error in
                    if let error = error {
                        print("Error updating achievements: \(error)")
                    } else {
                        self.loadAchievements()
                    }
                }
            }
    }
    
    private func checkStreakAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var currentStreak = 0
        var currentDate = today
        
        for log in logs {
            let logDate = calendar.startOfDay(for: log.date.dateValue())
            if calendar.isDate(logDate, inSameDayAs: currentDate) {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        let streakAchievements = [
            ("First Steps", 3),
            ("Momentum Builder", 7),
            ("Habit Master", 30),
            ("Dedicated User", 100)
        ]
        
        for (title, requiredStreak) in streakAchievements {
            if currentStreak >= requiredStreak {
                unlockAchievement(title: title, collection: collection, batch: batch)
            }
        }
    }
    
    private func checkCompletionAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        let perfectDays = logs.filter { $0.totalProgress >= 1.0 }.count
        
        var consecutivePerfectDays = 0
        var maxConsecutivePerfectDays = 0
        
        for log in logs {
            if log.totalProgress >= 1.0 {
                consecutivePerfectDays += 1
                maxConsecutivePerfectDays = max(maxConsecutivePerfectDays, consecutivePerfectDays)
            } else {
                consecutivePerfectDays = 0
            }
        }
        
        let totalGoalsCompleted = logs.reduce(0) { sum, log in
            sum + (log.totalProgress >= 1.0 ? 1 : 0)
        }
        
        if perfectDays > 0 {
            unlockAchievement(title: "Perfect Day", collection: collection, batch: batch)
        }
        
        if maxConsecutivePerfectDays >= 7 {
            unlockAchievement(title: "Perfect Week", collection: collection, batch: batch)
        }
        
        if totalGoalsCompleted >= 50 {
            unlockAchievement(title: "Goal Crusher", collection: collection, batch: batch)
        }
        
        if totalGoalsCompleted >= 100 {
            unlockAchievement(title: "Century Club", collection: collection, batch: batch)
        }
    }
    
    private func checkTimeBasedAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        guard let firstLog = logs.last else { return }
        
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day],
                                                   from: firstLog.date.dateValue(),
                                                   to: Date()).day ?? 0
        
        let timeBasedAchievements = [
            ("First Month", 30),
            ("Quarterly Success", 90),
            ("Half Year Hero", 180),
            ("Year of Growth", 365)
        ]
        
        for (title, requiredDays) in timeBasedAchievements {
            if daysSinceStart >= requiredDays {
                unlockAchievement(title: title, collection: collection, batch: batch)
            }
        }
    }
    
    private func checkSpecialAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        let calendar = Calendar.current
        
        // Check for early bird/night owl
        for log in logs {
            let date = log.date.dateValue()
            let hour = calendar.component(.hour, from: date)
            
            if hour <= 8 {
                unlockAchievement(title: "Early Bird", collection: collection, batch: batch)
            }
            
            if hour >= 22 {
                unlockAchievement(title: "Night Owl", collection: collection, batch: batch)
            }
        }
        
        // Check for comeback king
        if logs.count >= 2 {
            for i in 0..<logs.count-1 {
                let currentLogDate = logs[i].date.dateValue()
                let previousLogDate = logs[i+1].date.dateValue()
                
                let daysBetween = calendar.dateComponents([.day], from: previousLogDate, to: currentLogDate).day ?? 0
                
                if daysBetween >= 7 {
                    unlockAchievement(title: "Comeback King", collection: collection, batch: batch)
                    break
                }
            }
        }
    }
    
    private func unlockAchievement(title: String, collection: CollectionReference, batch: WriteBatch) {
        let achievementDoc = collection.document(title)
        
        let achievementData: [String: Any] = [
            "title": title,
            "dateEarned": Timestamp(date: Date())
        ]
        
        batch.setData(achievementData, forDocument: achievementDoc, merge: true)
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
