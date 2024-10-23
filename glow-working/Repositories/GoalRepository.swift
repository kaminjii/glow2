import FirebaseFirestore

class GoalRepository: ObservableObject {
    @Published var goals: [Goal] = []
    
    private let db = Firestore.firestore()
    
    // Fetch goals for a given date as Timestamp
    func fetchGoals(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Query Firestore for goals where the date is within the same day
        db.collection("goals")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
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
}
