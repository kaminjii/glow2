import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct GoalsView: View {
    @Binding var selectedTab: Int

    @StateObject private var goalRepository = GoalRepository()
    @State private var selectedGoal: Goal? = nil
    @State private var showActionSheet = false
    @State private var showAlert = false
    @State private var showEditGoal = false

    @State private var goals: [Goal] = []

    var body: some View {
        
        ZStack{
            Color.whitePrimary.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Goals")
                    .font(.title3).bold()
                    .foregroundStyle(.black1)
                    .padding()
                
                ScrollView {
                    GoalsList(goals: $goals, onGoalSelected: { selectedGoal in
                        self.selectedGoal = selectedGoal
                        self.showActionSheet = true
                    }, showValue: false)
                }
            }
            .onAppear {
                fetchGoalsForToday()
            }
            .confirmationDialog("", isPresented: $showActionSheet) {
//                Button("Edit Goal") {
//                    showEditGoal = true
//                }
                Button("Remove Goal", role: .destructive) {
                    showActionSheet = false
                    showAlert = true
                }
                .foregroundStyle(.red)
            }
            .alert("Remove Goal", isPresented: $showAlert) {
                Button("Cancel", role: .cancel)
                {
                    self.showAlert = false
                }
                Button("Remove", role: .destructive) {
                    deleteGoal(selectedGoal)
                    selectedGoal = nil
                    showAlert = false
                }
                
            }
//            .sheet(isPresented: $showEditGoal) {
//                EditGoalModal(goal: selectedGoal)
//            }

        }
    }

    private func fetchGoalsForToday() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Fetch goals for today
        Firestore.firestore().collection("goals")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error)")
                } else {
                    self.goals = querySnapshot?.documents.compactMap { document -> Goal? in
                        try? document.data(as: Goal.self)
                    } ?? []
                }
            }
    }
    
    private func addGoal() {
        let newGoal = Goal(
            id: nil,
            date: Timestamp(date: Date()),
            deleted: false,
            detail: "New Goal",
            icon: "star",
            name: "My Goal",
            quantityComplete: 0.0,
            quantityGoal: 1.0,
            unit: "units"
        )
        goalRepository.addGoal(newGoal)
    }
    
    private func editGoal(_ goal: Goal?) {
        guard let goal = goal else { return }
        selectedGoal = goal
        showEditGoal = true
    }

    private func deleteGoal(_ goal: Goal?) {
        guard let goal = goal, let goalId = goal.id else { return }

        // Update the deleted property of the goal to true in Firestore
        Firestore.firestore().collection("goals").document(goalId).updateData([
            "deleted": true
        ]) { error in
            if let error = error {
                print("Error marking goal as deleted: \(error)")
            } else {
                print("Goal marked as deleted successfully.")
                fetchGoalsForToday() // Refresh goals after deletion
            }
        }
    }

}



#Preview {
    GoalsView(selectedTab: .constant(3))
}
