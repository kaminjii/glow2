import SwiftUI
import FirebaseCore

struct GoalsList: View {
    @Binding var goals: [Goal]
    var onGoalSelected: (Goal) -> Void
    
    var body: some View {
        ForEach($goals) { goal in
            GoalItem(goal: goal)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .padding(.bottom, 16)
                .shadow(color: .blackShadow, radius: 10, y: 5)
                .onTapGesture {
                    onGoalSelected(goal.wrappedValue)
                }
        }
    }
}

#Preview {
    let sampleGoals = [
        Goal(id: "\(UUID())", date: Timestamp(date: Date()), deleted: false, detail: "Exercise for 1 hour", icon: "figure.run", name: "Exercise", quantityComplete: 0.5, quantityGoal: 1, unit: "hours"),
        Goal(id: "\(UUID())", date: Timestamp(date: Date()), deleted: false, detail: "Exercise for 1 hour", icon: "figure.run", name: "Exercise", quantityComplete: 0.5, quantityGoal: 1, unit: "hours")
    ]
    
    GoalsList(goals: .constant(sampleGoals), onGoalSelected: { _ in })
}
