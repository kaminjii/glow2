import FirebaseFirestore

class DailyLogRepository: ObservableObject {
    private let db = Firestore.firestore()
    
    func fetchDailyLogs(for date: Date, completion: @escaping ([DailyLog]) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("dailyLogs")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion([])
                } else {
                    let logs = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: DailyLog.self)
                    } ?? []
                    completion(logs)
                }
            }
    }
    
    func addDailyLog(_ dailyLog: DailyLog, completion: @escaping (Bool) -> Void) {
        do {
            let _ = try db.collection("dailyLogs").addDocument(from: dailyLog) { error in
                if let error = error {
                    print("Error adding daily log: \(error)")
                    completion(false)
                } else {
                    print("Successfully added daily log.")
                    completion(true)
                }
            }
        } catch let error {
            print("Error encoding daily log: \(error)")
            completion(false)
        }
    }
    
    func updateDailyLog(_ updatedLog: DailyLog, completion: @escaping (Bool) -> Void) {
        guard let id = updatedLog.id else { return }
        
        do {
            try db.collection("dailyLogs").document(id).setData(from: updatedLog) { error in
                if let error = error {
                    print("Error updating daily log: \(error)")
                    completion(false)
                } else {
                    print("Successfully updated daily log with ID: \(id)")
                    completion(true)
                }
            }
        } catch let error {
            print("Error encoding daily log: \(error)")
            completion(false)
        }
    }
    
    func createDailyLog(completion: @escaping () -> Void) {
        // Get the current date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get the start and end of today
        let todayStart = today
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: today)!

        // Check for existing daily log for today
        db.collection("dailyLogs")
            .whereField("date", isGreaterThan: Timestamp(date: todayStart))
            .whereField("date", isLessThan: Timestamp(date: todayEnd))
            .getDocuments { logSnapshot, logError in
                if let logError = logError {
                    print("Error fetching today's daily log: \(logError)")
                    completion() // Call completion in case of error
                    return
                }
                
                // Check if there is already a daily log for today
                if let logDocuments = logSnapshot?.documents, !logDocuments.isEmpty {
                    print("Daily log already exists for today. Skipping creation.")
                } else {
                    // If no daily log exists for today, create one
                    let dailyLogData: [String: Any] = [
                        "date": Timestamp(date: Date()),
                        "image": "",
                        "note": "",
                        "totalProgress": 0.0
                        
                    ]
                    
                    self.db.collection("dailyLogs").addDocument(data: dailyLogData) { error in
                        if let error = error {
                            print("Error adding new daily log: \(error)")
                        } else {
                            print("Successfully added daily log for today.")
                        }
                    }
                }
                completion() // Call completion after checking for the log
            }
    }
    
    func updateTotalProgress(for date: Date, completion: @escaping () -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date) // Start of the day
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)! // End of the day
        
        // Query all goals for the specified date range
        db.collection("goals")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error)")
                    completion()
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No goals found for today.")
                    // If no goals, you might want to set total progress to 0 or handle as needed
                    self.setTotalProgress(for: startOfDay, to: 0) {
                        completion()
                    }
                    return
                }
                
                // Calculate average progress
                let totalProgress = documents.reduce(0.0) { (result, document) in
                    let goalData = document.data()
                    let quantityComplete = goalData["quantityComplete"] as? Double ?? 0.0
                    let quantityGoal = goalData["quantityGoal"] as? Double ?? 1.0 // Avoid division by zero
                    
                    // Calculate percentage complete for this goal
                    let percentComplete = quantityGoal > 0 ? quantityComplete / quantityGoal : 0.0
                    return result + percentComplete
                }

                // Calculate average of percent completes
                let averageProgress = documents.isEmpty ? 0.0 : totalProgress / Double(documents.count)

                
                // Update the total progress in the daily log
                self.setTotalProgress(for: startOfDay, to: averageProgress) {
                    completion()
                }
            }
    }

        
    private func setTotalProgress(for date: Date, to totalProgress: Double, completion: @escaping () -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date) // Start of the day
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)! // End of the day
        
        // Check if a daily log exists for today
        db.collection("dailyLogs")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching daily log: \(error)")
                    completion()
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No daily log found for today.")
                    completion()
                    return
                }
                
                // Update the total progress in the found daily log
                let dailyLogRef = self.db.collection("dailyLogs").document(document.documentID)
                dailyLogRef.updateData(["totalProgress": totalProgress]) { error in
                    if let error = error {
                        print("Error updating total progress: \(error)")
                    } else {
                        print("Successfully updated total progress to \(totalProgress).")
                    }
                    completion()
                }
            }
    }
}
