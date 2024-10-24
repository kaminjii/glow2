import SwiftUI

struct TemplateGoalItem: View {
    @Binding var goal: TemplateGoal
    
    var body: some View {
        HStack {
            GradientIcon(iconName: goal.iconName)

            VStack(alignment: .leading, spacing: 0) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundStyle(.black1)
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(.gray1)
            }
            .padding(.horizontal, 10)
            
            Spacer()

            CheckBoxView(checked: $goal.checked)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleGoal = TemplateGoal(iconName: "figure.run", title: "Exercise", description: "Exercise for 1 hour", checked: false)
    
    TemplateGoalItem(goal: .constant(sampleGoal))
}
