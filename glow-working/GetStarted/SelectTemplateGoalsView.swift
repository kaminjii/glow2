import SwiftUI

struct SelectTemplateGoalsView: View {
    @State var templateGoals: [TemplateGoal] = [
        TemplateGoal(iconName: "figure.run", title: "Exercise", description: "Exercise for 1 hour", checked: false),
        TemplateGoal(iconName: "book.fill", title: "Read", description: "Read for 30 minutes", checked: false),
        TemplateGoal(iconName: "flame.fill", title: "Diet", description: "Eat healthy meals", checked: false),
        TemplateGoal(iconName: "bed.double.fill", title: "Sleep", description: "Get 8 hours of sleep", checked: false)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                Text("What would you like to \ntrack?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 100)
                    .font(.title)

                ForEach(templateGoals.indices, id: \.self) { index in
                    TemplateGoalItem(goal: $templateGoals[index])
                        .padding(.vertical, 5)
                        .shadow(color: .blackShadow, radius: 20, y: 10)
                }
                
                AddOtherGoal()
                    .padding(.vertical, 5)
                    .shadow(color: .blackShadow, radius: 20, y: 10)

                Spacer()
            }
            
            VStack {
                Spacer()
                
                GradientButton(title: "Done", action: {}, isEnabled: true)
                    .padding(.bottom, 40)
            }
        }
        .padding(.horizontal)
        .ignoresSafeArea(edges: .all)
        .background(.whitePrimary)
    }
}

#Preview {
    SelectTemplateGoalsView()
}
