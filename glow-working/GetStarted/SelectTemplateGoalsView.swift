import SwiftUI

struct SelectTemplateGoalsView: View {
    @State private var done: Bool = false
    @State private var showAddGoal: Bool = false
    
    // Track selected goal indices
    @State private var selectedGoals: Set<Int> = []
    
    @State var templateGoals: [TemplateGoal] = [
        TemplateGoal(iconName: "figure.run", title: "Exercise", description: "Exercise for 1 hour", checked: false),
        TemplateGoal(iconName: "book.fill", title: "Read", description: "Read for 30 minutes", checked: false),
        TemplateGoal(iconName: "flame.fill", title: "Diet", description: "Eat healthy meals", checked: false),
        TemplateGoal(iconName: "bed.double.fill", title: "Sleep", description: "Get 8 hours of sleep", checked: false)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("What would you like to \ntrack?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .font(.title)
                    
                    ScrollView {
                        ForEach(templateGoals.indices, id: \.self) { index in
                            TemplateGoalItem(goal: $templateGoals[index])
                                .padding(.vertical, 5)
                                .shadow(color: .blackShadow, radius: 20, y: 10)
                                .onTapGesture {
                                    // Toggle selection
                                    if selectedGoals.contains(index) {
                                        selectedGoals.remove(index)
                                    } else {
                                        selectedGoals.insert(index)
                                    }
                                }
                        }
                        .padding(.horizontal)
                    
                        
                        AddOtherGoal(isPresented: $showAddGoal)
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                            .shadow(color: .blackShadow, radius: 20, y: 10)
                        Spacer()
                    }
                }
                
                VStack {
                    Spacer()
                    
                    GradientButton(title: "Done", action: {
                        // Update selected goals to be checked
                        for index in selectedGoals {
                            templateGoals[index].checked = true
                        }
                        // Optionally clear selected goals after done
                        selectedGoals.removeAll()
                        done = true
                    }, isEnabled: true)
                        .padding()
                        .padding(.bottom)
                        .background(.whitePrimary)
 
                }
            }
            .navigationDestination(isPresented: $done) {
                ContentView()
            }
            .toolbarVisibility(.hidden)
            .sheet(isPresented: $showAddGoal) {
                AddGoalModal { newGoal in
                    // Add the new goal to the templateGoals
                    templateGoals.append(newGoal)
                }
            }
        }
    }
}

#Preview {
    SelectTemplateGoalsView()
}
