//
//  StatsManager.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import FirebaseFirestore
import FirebaseAuth
import Combine

class StatsManager: ObservableObject {
    @Published var recordedDays = 0
    @Published var streak = 0
    
    private let db = Firestore.firestore()
    
    /// Calculates user statistics including recorded days and current streak
    func calculateStats() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Calculate total recorded days
        db.collection("users").document(userId).collection("dailyLogs")
            .getDocuments { [weak self] snapshot, error in
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.recordedDays = count
                }
            }
        
        calculateStreak()
    }
    
    /// Calculates the current streak of consecutive logged days
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
                
                // Iterate through logs to calculate streak
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
}
