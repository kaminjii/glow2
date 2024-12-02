import SwiftUI
import FirebaseCore

struct GoalsList: View {
    @Binding var goals: [Goal]
    var onGoalSelected: (Goal) -> Void
    var showValue: Bool
    
    var body: some View {
        ForEach($goals) { goal in
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
