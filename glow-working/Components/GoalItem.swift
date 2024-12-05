import SwiftUI
import FirebaseCore

// View representing a single goal item in a list
struct GoalItem: View {
    @Binding var goal: Goal
    var onGoalSelected: (Goal) -> Void // Callback when the goal is selected
    var showValue: Bool

    init(goal: Binding<Goal>, onGoalSelected: @escaping (Goal) -> Void, showValue: Bool = true) {
        self._goal = goal
        self.onGoalSelected = onGoalSelected
        self.showValue = showValue
    }

    var body: some View {
        HStack {
            GradientIcon(iconName: goal.icon)
            
            // Goal name and optional detail displayed in a vertical stack
            VStack(alignment: .leading, spacing: 0) {
                Text(goal.name)
                    .font(.headline)
                    .foregroundStyle(.black1)
                Text(goal.detail ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray1)
            }
            .padding(.horizontal, 10)
            
            Spacer()
            
            // Show the progress percentage if `showValue` is true
            if showValue {
                Text("\(Int((Double(goal.quantityComplete) / Double(goal.quantityGoal)) * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
            }
            
            // Button with ellipsis to trigger the `onGoalSelected` callback
            Button(action: {
                onGoalSelected(goal)
            }) {
                Image(systemName: "ellipsis")
            }
            .foregroundColor(.black1)
            .frame(height: 50)
        }
    }
}

#Preview {
    let sampleGoal = Goal(id: "\(UUID())", date: Timestamp(date: Date()), deleted: false, detail: "Exercise for 1 hour", icon: "figure.run", name: "Exercise", quantityComplete: 0.5, quantityGoal: 1, unit: "hours")
    
    GoalItem(goal: .constant(sampleGoal), onGoalSelected: { _ in }, showValue: true)
}
