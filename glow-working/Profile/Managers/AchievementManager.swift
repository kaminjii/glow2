//
//  AchievementManager.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import FirebaseFirestore
import FirebaseAuth
import Combine

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    private let db = Firestore.firestore()
    
    /// List of all possible achievements
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
    
    /// Loads and updates achievement status from Firestore
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
    
    /// Refreshes all achievements
    func refreshAchievements() {
        checkAndUpdateAchievements()
    }
    
    /// Checks and updates all achievement categories
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
                self.checkTimeBasedAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkProgressAchievements(logs: logs, collection: achievementsCollection, batch: batch)
                self.checkCompletionAchievements(logs: logs, collection: achievementsCollection, batch: batch)
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
    
    // MARK: - Achievement Checking Methods
    
    private func checkStreakAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        // Implementation from original file...
    }
    
    private func checkTimeBasedAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        // Implementation from original file...
    }
    
    private func checkProgressAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        // Implementation from original file...
    }
    
    private func checkCompletionAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        // Implementation from original file...
    }
    
    private func checkSpecialAchievements(logs: [DailyLog], collection: CollectionReference, batch: WriteBatch) {
        // Implementation from original file...
    }
    
    /// Unlocks an achievement in Firestore
    private func unlockAchievement(title: String, collection: CollectionReference, batch: WriteBatch) {
        let achievementDoc = collection.document(title)
        
        let achievementData: [String: Any] = [
            "title": title,
            "dateEarned": Timestamp(date: Date())
        ]
        
        batch.setData(achievementData, forDocument: achievementDoc, merge: true)
    }
}
