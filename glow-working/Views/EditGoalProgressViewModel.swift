
import Foundation
import FirebaseFirestore

class EditGoalProgressViewModel: ObservableObject {
    @Published var goal: Goal
    @Published var inputValue: String = ""
    
    private var db = Firestore.firestore()
    
    init(goal: Goal) {
        self.goal = goal
        self.inputValue = String(format: "%.2f", goal.quantityComplete)
    }
    
    func fetchGoalData() {
        // Fetch goal data from Firestore
        db.collection("goals").document(goal.id!).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    self.goal = try document.data(as: Goal.self)
                    self.inputValue = String(format: "%.2f", self.goal.quantityComplete)
                } catch {
                    print("Error decoding goal: \(error)")
                }
            } else {
                print("Goal not found: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func saveGoal(completion: @escaping () -> Void) {
        do {
            let goalRef = db.collection("goals").document(goal.id!)
            try goalRef.setData(from: goal) { error in
                if let error = error {
                    print("Error saving goal: \(error)")
                } else {
                    completion()
                }
            }
        } catch {
            print("Error saving goal: \(error)")
        }
    }
}
