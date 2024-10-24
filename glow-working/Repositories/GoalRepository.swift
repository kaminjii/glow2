import FirebaseFirestore
import FirebaseCore

class GoalRepository: ObservableObject {
    @Published var goals: [Goal] = []
    
    // Change access level from private to internal
    private let db = Firestore.firestore()
    
    // Fetch goals for a given date as Timestamp
    func fetchGoals(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("goals")
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
    
    // Add a new goal
    func addGoal(_ goal: Goal) {
        do {
            let _ = try db.collection("goals").addDocument(from: goal) { error in
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
    
    // Update an existing goal
    func updateGoal(_ updatedGoal: Goal) {
        guard let id = updatedGoal.id else { return }
        
        do {
            try db.collection("goals").document(id).setData(from: updatedGoal) { error in
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
        // Get the current date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get the start and end of today
        let todayStart = today
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: today)!

        // Query Firestore for goals from today
        db.collection("goals")
            .whereField("date", isGreaterThan: Timestamp(date: todayStart))
            .whereField("date", isLessThan: Timestamp(date: todayEnd))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching today's goals: \(error)")
                    completion() // Call completion in case of error
                    return
                }
                
                // Check if there are existing goals for today
                if let documents = snapshot?.documents, !documents.isEmpty {
                    print("Goals already exist for today. Skipping creation.")
                    completion() // Call completion if goals already exist
                    return
                }
                
                // If no goals exist for today, proceed to create new goals
                // Fetch goals from the previous day
                let previousStart = calendar.date(byAdding: .day, value: -1, to: today)!
                let previousEnd = calendar.date(byAdding: .day, value: 0, to: today)!

                // Query Firestore for goals from the previous day
                self.db.collection("goals")
                    .whereField("date", isGreaterThan: Timestamp(date: previousStart))
                    .whereField("date", isLessThan: Timestamp(date: previousEnd))
                    .whereField("deleted", isEqualTo: false)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching goals: \(error)")
                            completion() // Call completion in case of error
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            completion() // Call completion if no documents found
                            return
                        }
                        
                        for document in documents {
                            let goalData = document.data()
                            let newGoal = Goal(
                                id: nil, // Firestore will generate this
                                date: Timestamp(date: Date()),
                                deleted: false,
                                detail: goalData["detail"] as? String ?? "",
                                icon: goalData["icon"] as? String ?? "",
                                name: goalData["name"] as? String ?? "",
                                quantityComplete: 0.0,
                                quantityGoal: goalData["quantityGoal"] as? Double ?? 0.0,
                                unit: goalData["unit"] as? String ?? ""
                            )
                            
                            // Save the new goal to Firestore
                            self.db.collection("goals").addDocument(data: [
                                "date": newGoal.date,
                                "deleted": newGoal.deleted,
                                "detail": newGoal.detail!,
                                "icon": newGoal.icon,
                                "name": newGoal.name,
                                "quantityComplete": newGoal.quantityComplete,
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
                        completion() // Call completion after processing all documents
                    }
            }
    }

}
