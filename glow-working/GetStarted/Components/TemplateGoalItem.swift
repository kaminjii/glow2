import SwiftUI

struct TemplateGoalItem: View {
    @Binding var goal: TemplateGoal
    var onToggle: () -> Void
    
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

            CheckBoxView(checked: $goal.checked, onToggle: onToggle)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .frame(maxWidth: .infinity)
        .onTapGesture {
            goal.checked.toggle()
            onToggle() 
        }
    }
}
