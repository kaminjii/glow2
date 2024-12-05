import SwiftUI
import FirebaseCore

// View that displays a list of goals
struct GoalsList: View {
    @Binding var goals: [Goal]
    var onGoalSelected: (Goal) -> Void // Callback when a goal is selected
    var showValue: Bool
    
    var body: some View {
        // Iterate through the goals array using `ForEach`
        ForEach($goals) { goal in
            // Render each goal as a `GoalItem` view
            GoalItem(goal: goal, onGoalSelected: onGoalSelected, showValue: showValue)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .shadow(color: .blackShadow, radius: 10, y: 5)
                .padding(.bottom, 5)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    let sampleGoals = [
        Goal(id: "\(UUID())", date: Timestamp(date: Date()), deleted: false, detail: "Exercise for 1 hour", icon: "figure.run", name: "Exercise", quantityComplete: 0.5, quantityGoal: 1, unit: "hours"),
        Goal(id: "\(UUID())", date: Timestamp(date: Date()), deleted: false, detail: "Exercise for 1 hour", icon: "figure.run", name: "Exercise", quantityComplete: 0.5, quantityGoal: 1, unit: "hours")
    ]
    
    GoalsList(goals: .constant(sampleGoals), onGoalSelected: { _ in }, showValue: true)
}
