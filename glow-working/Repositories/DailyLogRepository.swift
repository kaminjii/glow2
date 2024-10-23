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
}
