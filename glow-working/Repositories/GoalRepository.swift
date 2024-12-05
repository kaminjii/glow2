import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

class GoalRepository: ObservableObject {
    @Published var goals: [Goal] = []
    private let db = Firestore.firestore()
    
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    private func getUserGoalsCollection() -> CollectionReference? {
        guard let userId = getCurrentUserId() else { return nil }
        return db.collection("users").document(userId).collection("goals")
    }
    
    func fetchGoals(for date: Date) {
        guard let goalsCollection = getUserGoalsCollection() else {
            self.goals = []
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        goalsCollection
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching goals: \(error)")
                } else {
                    self.goals = querySnapshot?.documents.compactMap { document -> Goal? in
                        try? document.data(as: Goal.self)
                    } ?? []
                }
            }
    }
    
    func addGoal(_ goal: Goal) {
        guard let goalsCollection = getUserGoalsCollection() else {
            return
        }
        
        do {
            let _ = try goalsCollection.addDocument(from: goal) { error in
                if let error = error {
                    print("Error adding goal: \(error)")
                } else {
                    print("Successfully added goal.")
                    self.fetchGoals(for: goal.date.dateValue())
                }
            }
        } catch let error {
            print("Error encoding goal: \(error)")
        }
    }
    
    func updateGoal(_ updatedGoal: Goal) {
        guard let goalsCollection = getUserGoalsCollection(),
              let id = updatedGoal.id else { return }
        
        do {
            try goalsCollection.document(id).setData(from: updatedGoal) { error in
                if let error = error {
                    print("Error updating goal: \(error)")
                } else {
                    print("Successfully updated goal with ID: \(id)")
                    self.fetchGoals(for: updatedGoal.date.dateValue())
                }
            }
        } catch let error {
            print("Error encoding goal: \(error)")
        }
    }
    
    func createDailyGoals(completion: @escaping (Bool) -> Void) {
        guard let goalsCollection = getUserGoalsCollection() else {
            completion(false)
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayStart = today
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // First check if goals already exist for today
        goalsCollection
            .whereField("date", isGreaterThan: Timestamp(date: todayStart))
            .whereField("date", isLessThan: Timestamp(date: todayEnd))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching today's goals: \(error)")
                    completion(false)
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Goals already exist for today. Skipping creation.")
                    completion(true)
                    return
                }
                
                // First, get the most recent date that had goals
                goalsCollection
                    .whereField("date", isLessThan: Timestamp(date: todayStart))
                    .whereField("deleted", isEqualTo: false)
                    .order(by: "date", descending: true)
                    .limit(to: 1)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching most recent goal date: \(error)")
                            completion(false)
                            return
                        }
                        
                        guard let mostRecentDoc = snapshot?.documents.first,
                              let mostRecentDate = (mostRecentDoc.data()["date"] as? Timestamp)?.dateValue() else {
                            completion(false)
                            return
                        }
                        
                        // Then get all goals from that most recent date
                        let startOfMostRecentDay = calendar.startOfDay(for: mostRecentDate)
                        let endOfMostRecentDay = calendar.date(byAdding: .day, value: 1, to: startOfMostRecentDay)!
                        
                        goalsCollection
                            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfMostRecentDay))
                            .whereField("date", isLessThan: Timestamp(date: endOfMostRecentDay))
                            .whereField("deleted", isEqualTo: false)
                            .getDocuments { snapshot, error in
                                if let error = error {
                                    print("Error fetching most recent day's goals: \(error)")
                                    completion(false)
                                    return
                                }
                                
                                guard let documents = snapshot?.documents else {
                                    completion(false)
                                    return
                                }
                                
                                // Keep track of how many goals we've processed
                                var goalsProcessed = 0
                                let totalGoals = documents.count
                                
                                for document in documents {
                                    let goalData = document.data()
                                    let newGoal = Goal(
                                        id: nil,
                                        date: Timestamp(date: Date()),
                                        deleted: false,
                                        detail: goalData["detail"] as? String ?? "",
                                        icon: goalData["icon"] as? String ?? "",
                                        name: goalData["name"] as? String ?? "",
                                        quantityComplete: 0.0,
                                        quantityGoal: goalData["quantityGoal"] as? Double ?? 0.0,
                                        unit: goalData["unit"] as? String ?? ""
                                    )
                                    
                                    goalsCollection.addDocument(data: [
                                        "date": newGoal.date,
                                        "deleted": newGoal.deleted,
                                        "detail": newGoal.detail!,
                                        "icon": newGoal.icon,
                                        "name": newGoal.name,
                                        "quantityComplete": 0.0,
                                        "quantityGoal": newGoal.quantityGoal,
                                        "unit": newGoal.unit
                                    ]) { error in
                                        goalsProcessed += 1
                                        
                                        if let error = error {
                                            print("Error adding new goal: \(error)")
                                        } else {
                                            print("Successfully added goal: \(newGoal.name)")
                                        }
                                        
                                        // Only call completion when all goals have been processed
                                        if goalsProcessed == totalGoals {
                                            completion(true)
                                        }
                                    }
                                }
                                
                                // If there were no goals to process, complete immediately
                                if totalGoals == 0 {
                                    completion(true)
                                }
                            }
                    }
            }
    }
}
