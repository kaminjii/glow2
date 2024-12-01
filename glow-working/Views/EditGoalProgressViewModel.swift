import Foundation
import FirebaseFirestore
import FirebaseAuth

class EditGoalProgressViewModel: ObservableObject {
    @Published var goal: Goal
    @Published var inputValue: String = ""
    
    private var db = Firestore.firestore()
    
    init(goal: Goal) {
        self.goal = goal
        self.inputValue = String(format: "%.2f", goal.quantityComplete)
    }
    
    func fetchGoalData() {
        guard let userId = Auth.auth().currentUser?.uid,
              let goalId = goal.id else {
            print("Missing user ID or goal ID")
            return
        }
        
        db.collection("users").document(userId).collection("goals")
            .document(goalId)
            .getDocument { [weak self] document, error in
                if let error = error {
                    print("Error fetching goal: \(error)")
                    return
                }
                
                if let document = document,
                   let updatedGoal = try? document.data(as: Goal.self) {
                    DispatchQueue.main.async {
                        self?.goal = updatedGoal
                        self?.inputValue = String(format: "%.2f", updatedGoal.quantityComplete)
                    }
                }
            }
    }
    
    func saveGoal(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid,
              let goalId = goal.id else {
            print("Missing user ID or goal ID")
            return
        }
        
        let goalRef = db.collection("users").document(userId).collection("goals")
            .document(goalId)
        
        do {
            try goalRef.setData(from: goal) { error in
                if let error = error {
                    print("Error saving goal: \(error)")
                } else {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        } catch {
            print("Error encoding goal: \(error)")
        }
    }
}
