import FirebaseFirestore
import FirebaseAuth

class DailyLogRepository: ObservableObject {
    private let db = Firestore.firestore()
    
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    private func getUserDailyLogsCollection() -> CollectionReference? {
        guard let userId = getCurrentUserId() else { return nil }
        return db.collection("users").document(userId).collection("dailyLogs")
    }
    
    func fetchDailyLogs(for date: Date, completion: @escaping ([DailyLog]) -> Void) {
        guard let logsCollection = getUserDailyLogsCollection() else {
             completion([])
             return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        logsCollection
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
        guard let logsCollection = getUserDailyLogsCollection() else {
            completion(false)
            return
        }
        
        do {
            let _ = try logsCollection.addDocument(from: dailyLog) { error in
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
        guard let logsCollection = getUserDailyLogsCollection(),
              let id = updatedLog.id else {
            completion(false)
            return
        }
        
        do {
            try logsCollection.document(id).setData(from: updatedLog) { error in
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
        guard let logsCollection = getUserDailyLogsCollection() else {
            completion()
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: today)!
        
        logsCollection
            .whereField("date", isGreaterThan: Timestamp(date: today))
            .whereField("date", isLessThan: Timestamp(date: todayEnd))
            .getDocuments { logSnapshot, logError in
                if let logError = logError {
                    print("Error fetching today's daily log: \(logError)")
                    completion()
                    return
                }
                
                if let logDocuments = logSnapshot?.documents, !logDocuments.isEmpty {
                    print("Daily log already exists for today. Skipping creation.")
                } else {
                    let dailyLogData: [String: Any] = [
                        "date": Timestamp(date: Date()),
                        "image": "",
                        "note": "",
                        "totalProgress": 0.0
                    ]
                    
                    logsCollection.addDocument(data: dailyLogData) { error in
                        if let error = error {
                            print("Error adding new daily log: \(error)")
                        } else {
                            print("Successfully added daily log for today.")
                        }
                        completion()
                    }
                }
            }
    }
    
    func updateTotalProgress(for date: Date, completion: @escaping () -> Void) {
        guard let userId = getCurrentUserId() else {
            completion()
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let goalsCollection = db.collection("users").document(userId).collection("goals")
        
        goalsCollection
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
                    self.setTotalProgress(for: startOfDay, to: 0) {
                        completion()
                    }
                    return
                }
                
                let totalProgress = documents.reduce(0.0) { (result, document) in
                    let goalData = document.data()
                    let quantityComplete = goalData["quantityComplete"] as? Double ?? 0.0
                    let quantityGoal = goalData["quantityGoal"] as? Double ?? 1.0
                    let percentComplete = quantityGoal > 0 ? quantityComplete / quantityGoal : 0.0
                    return result + percentComplete
                }
                
                let averageProgress = documents.isEmpty ? 0.0 : totalProgress / Double(documents.count)
                
                self.setTotalProgress(for: startOfDay, to: averageProgress) {
                    completion()
                }
            }
    }
        
    private func setTotalProgress(for date: Date, to totalProgress: Double, completion: @escaping () -> Void) {
        guard let logsCollection = getUserDailyLogsCollection() else {
            completion()
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        logsCollection
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
                
                let dailyLogRef = logsCollection.document(document.documentID)
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
