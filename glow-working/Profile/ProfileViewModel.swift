//
//  ProfileViewModel.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/2/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Manages user profile data and logic, such as achievements, profile updates, and activity metrics
class ProfileViewModel: ObservableObject {
    // Published properties to store and update UI-related data
    @Published var fullName = "" // user's name
    @Published var email = "" // user's email
    @Published var showEditProfile = false // toggles edit profile view
    @Published var showChangePassword = false // toggles change password view
    @Published var achievements: [Achievement] = [] // list of all user achievements
    @Published var recordedDays = 0 // total number of days user has logged activity
    @Published var streak = 0 // current streak of consecutive logged activity days
    @Published var showReauthDialog = false
    @Published var deleteError: String?
    @Published var reauthPassword = ""
    @Published var isProcessingDelete = false
    
    private let db = Firestore.firestore()
    
    var starImage: String {
        return "star3"
    }
    
    // Calculates number of achievements user has unlocked
    var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    // Returns number of possible achievements available
    var totalAchievements: Int {
        AchievementManager.achievements.count
    }
    
    // Initializes the ViewModel and loads user data, achievements, and stats
    init() {
        loadUserData()
        loadAchievements()
        calculateStats()
        checkAndUpdateAchievements()
    }
    
    // Loads the user's profile data from Firestore and updates the ViewModel.
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is logged in
        
        // Fetch user document from Firestore
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self,
                  let data = document?.data() else { return }
            
            DispatchQueue.main.async {
                self.fullName = data["fullName"] as? String ?? "" // Update full name
                self.email = data["email"] as? String ?? "" // Update email
            }
        }
    }
    
    // Loads all available achievements and updates their unlocked status based on Firestore data.
    func loadAchievements() {
        self.achievements = AchievementManager.achievements // Load predefined achievements
        
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is logged in
        
        // Fetch unlocked achievements from Firestore
        db.collection("users").document(userId).collection("achievements")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                // Create a set of titles of unlocked achievements
                let unlockedTitles = Set(documents.compactMap { $0["title"] as? String })
                
                // Update the unlocked status for achievements
                DispatchQueue.main.async {
                    self?.achievements = self?.achievements.map { achievement in
                        var updatedAchievement = achievement
                        updatedAchievement.isUnlocked = unlockedTitles.contains(achievement.title)
                        return updatedAchievement
                    } ?? []
                }
            }
    }
    
    // Calculates user's activity statistics such as recorded days and streak.
    private func calculateStats() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is logged in
        
        // Calculate recorded days
        db.collection("users").document(userId).collection("dailyLogs")
            .getDocuments { [weak self] snapshot, error in
                let count = snapshot?.documents.count ?? 0 // Count total logs
                DispatchQueue.main.async {
                    self?.recordedDays = count
                }
            }
        
        // Calculate streak
        calculateStreak()
    }
    
    // Calculates the user's current streak of consecutive logged activity days.
    private func calculateStreak() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is logged in
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Fetch daily logs sorted by date in descending order
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
                        break // Streak is broken
                    }
                }
                
                DispatchQueue.main.async {
                    self?.streak = currentStreak
                }
            }
    }
    
    // Updates the user's profile data in Firestore.
    func updateProfile() async {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is logged in
        
        let data: [String: Any] = [
            "fullName": fullName,
            "email": email
        ]
        
        do {
            // Save updated profile data to Firestore
            try await db.collection("users").document(userId).setData(data, merge: true)
        } catch {
            print("Failed to update profile: \(error.localizedDescription)")
        }
    }
    
    // Updates the user's password in Firebase Auth.
    func updatePassword(currentPassword: String, newPassword: String) async {
        guard let user = Auth.auth().currentUser else { return } // Ensure user is logged in
        
        // Reauthenticate user
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        do {
            try await user.reauthenticate(with: credential) // Reauthenticate user
            try await user.updatePassword(to: newPassword) // Update password
        } catch {
            print("Error updating password: \(error.localizedDescription)")
        }
    }
    
    // Deletes the user's account and Firestore data.
    func deleteAccount() {
        // Show re-authentication dialog
        showReauthDialog = true
    }
    
    func confirmDeleteAccount(password: String) async -> Bool {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            deleteError = "No user found"
            return false
        }
        
        isProcessingDelete = true
        defer { isProcessingDelete = false }
        
        do {
            // First re-authenticate
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)
            
            // Delete Firestore data
            let userDoc = db.collection("users").document(user.uid)
            
            // Delete user subcollections
            let subcollections = ["dailyLogs", "goals", "achievements"]
            for collection in subcollections {
                let snapshot = try await userDoc.collection(collection).getDocuments()
                for document in snapshot.documents {
                    try await document.reference.delete()
                }
            }
            
            // Delete user document
            try await userDoc.delete()
            
            // Finally delete the auth account
            try await user.delete()
            
            return true
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.wrongPassword.rawValue:
                deleteError = "Incorrect password"
            case AuthErrorCode.tooManyRequests.rawValue:
                deleteError = "Too many attempts. Please try again later"
            default:
                deleteError = "Failed to delete account: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Achievement Logic
    
    // Refreshes the user's achievements by rechecking criteria.
    func refreshAchievements() {
        checkAndUpdateAchievements()
    }

    private func checkProgressAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        // Getting Started - Track your first goal
        if !logs.isEmpty {
            unlockAchievement(title: "Getting Started", collection: collection, batch: batch)
        }
        
        // Progress Pioneer - Reach 50% completion on all goals
        let daysWithAllGoals50Percent = logs.filter { log in
            log.totalProgress >= 0.5
        }.count
        
        if daysWithAllGoals50Percent > 0 {
            unlockAchievement(title: "Progress Pioneer", collection: collection, batch: batch)
        }
        
        // Consistency King - Maintain 80% completion for a week
        var consecutiveDaysOver80 = 0
        var maxConsecutiveDaysOver80 = 0
        let calendar = Calendar.current
        var previousDate: Date?
        
        for log in logs {
            let currentDate = calendar.startOfDay(for: log.date.dateValue())
            
            if log.totalProgress >= 0.8 {
                if let prevDate = previousDate {
                    let daysBetween = calendar.dateComponents([.day], from: currentDate, to: prevDate).day ?? 0
                    if daysBetween == 1 {
                        consecutiveDaysOver80 += 1
                    } else {
                        consecutiveDaysOver80 = 1
                    }
                } else {
                    consecutiveDaysOver80 = 1
                }
                maxConsecutiveDaysOver80 = max(maxConsecutiveDaysOver80, consecutiveDaysOver80)
            } else {
                consecutiveDaysOver80 = 0
            }
            previousDate = currentDate
        }
        
        if maxConsecutiveDaysOver80 >= 7 {
            unlockAchievement(title: "Consistency King", collection: collection, batch: batch)
        }
    }

    private func updateCheckCompletionAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        let calendar = Calendar.current
        let perfectDays = logs.filter { $0.totalProgress >= 1.0 }.count
        
        // Track consecutive perfect days
        var consecutivePerfectDays = 0
        var maxConsecutivePerfectDays = 0
        var previousDate: Date?
        
        for log in logs {
            let currentDate = calendar.startOfDay(for: log.date.dateValue())
            
            if log.totalProgress >= 1.0 {
                if let prevDate = previousDate {
                    let daysBetween = calendar.dateComponents([.day], from: currentDate, to: prevDate).day ?? 0
                    if daysBetween == 1 {
                        consecutivePerfectDays += 1
                    } else {
                        consecutivePerfectDays = 1
                    }
                } else {
                    consecutivePerfectDays = 1
                }
                maxConsecutivePerfectDays = max(maxConsecutivePerfectDays, consecutivePerfectDays)
            } else {
                consecutivePerfectDays = 0
            }
            previousDate = currentDate
        }
        
        // Perfect Day
        if perfectDays > 0 {
            unlockAchievement(title: "Perfect Day", collection: collection, batch: batch)
        }
        
        // Perfect Week
        if maxConsecutivePerfectDays >= 7 {
            unlockAchievement(title: "Perfect Week", collection: collection, batch: batch)
        }
        
        // Goal Crusher & Century Club
        // Using totalProgress as an indicator of completed goals
        // Assuming a progress of 1.0 means all goals for that day were completed
        let totalCompletedDays = logs.filter { $0.totalProgress >= 1.0 }.count
        
        if totalCompletedDays >= 50 {
            unlockAchievement(title: "Goal Crusher", collection: collection, batch: batch)
        }
        
        if totalCompletedDays >= 100 {
            unlockAchievement(title: "Century Club", collection: collection, batch: batch)
        }
    }
    
    private func updateCheckSpecialAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        let calendar = Calendar.current
        
        // Early Bird & Night Owl
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
        
        // Weekend Warrior
        var weekendPerfectDays = [Date: Bool]()
        for log in logs {
            let date = log.date.dateValue()
            let weekday = calendar.component(.weekday, from: date)
            
            // Check if it's weekend (Saturday or Sunday)
            if weekday == 1 || weekday == 7 {
                if log.totalProgress >= 1.0 {
                    weekendPerfectDays[calendar.startOfDay(for: date)] = true
                }
            }
        }
        
        // Check if there are 8 weekend days (equivalent to a month of weekends)
        if weekendPerfectDays.count >= 8 {
            unlockAchievement(title: "Weekend Warrior", collection: collection, batch: batch)
        }
        
        // Comeback King
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

    // Update the checkAndUpdateAchievements function to use the new checks
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
                self.updateCheckCompletionAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkProgressAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkTimeBasedAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.updateCheckSpecialAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                
                batch.commit { error in
                    if let error = error {
                        print("Error updating achievements: \(error)")
                    } else {
                        self.loadAchievements()
                    }
                }
            }
    }
    
    // Checks a user's streak achievements based on requirement
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
    
    // Checks a user's completion achievements based on requirements
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
    
    // Checks a user's time-based achievements based on requirements
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
    
    // Checks a user's special achievements based on requirements
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
    
    // provides unlocked achievements
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

// Provides pre-defined achievements for App
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
