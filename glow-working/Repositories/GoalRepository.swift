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
    
    func createDailyGoals(completion: @escaping () -> Void) {
        guard let goalsCollection = getUserGoalsCollection() else {
            completion()
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayStart = today
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: today)!
        
        goalsCollection
            .whereField("date", isGreaterThan: Timestamp(date: todayStart))
            .whereField("date", isLessThan: Timestamp(date: todayEnd))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching today's goals: \(error)")
                    completion()
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Goals already exist for today. Skipping creation.")
                    completion()
                    return
                }
                
                let previousStart = calendar.date(byAdding: .day, value: -1, to: today)!
                let previousEnd = calendar.date(byAdding: .day, value: 0, to: today)!
                
                goalsCollection
                    .whereField("date", isGreaterThan: Timestamp(date: previousStart))
                    .whereField("date", isLessThan: Timestamp(date: previousEnd))
                    .whereField("deleted", isEqualTo: false)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching goals: \(error)")
                            completion()
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            completion()
                            return
                        }
                        
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
                                if let error = error {
                                    print("Error adding new goal: \(error)")
                                } else {
                                    print("Successfully added goal: \(newGoal.name)")
                                }
                            }
                        }
                        completion()
                    }
            }
    }
}
