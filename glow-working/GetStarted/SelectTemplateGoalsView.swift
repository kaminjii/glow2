import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SelectTemplateGoalsView: View {
    @State private var done: Bool = false
    @State private var showAddGoal: Bool = false
    @State private var selectedGoals: Set<Int> = []
    @State private var isProcessing: Bool = false
    
    @State var templateGoals: [TemplateGoal] = [
        TemplateGoal(iconName: "figure.run", title: "Exercise", description: "Exercise for 1 hour", checked: false),
        TemplateGoal(iconName: "book.fill", title: "Read", description: "Read for 30 minutes", checked: false),
        TemplateGoal(iconName: "flame.fill", title: "Diet", description: "Eat healthy meals", checked: false),
        TemplateGoal(iconName: "bed.double.fill", title: "Sleep", description: "Get 8 hours of sleep", checked: false)
    ]
    
    private func getGoalDetails(for title: String) -> (unit: String, quantityGoal: Double) {
        switch title.lowercased() {
        case "exercise":
            return ("minutes", 60.0)
        case "read":
            return ("minutes", 30.0)
        case "diet":
            return ("meals", 3.0)
        case "sleep":
            return ("hours", 8.0)
        default:
            return ("completion", 1.0)
        }
    }
    
    private func addSelectedGoalsToFirestore() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            return
        }
        
        let db = Firestore.firestore()
        let goalsCollection = db.collection("users").document(userId).collection("goals")
        
        do {
            // Add each selected goal to Firestore
            for index in selectedGoals {
                let goal = templateGoals[index]
                let (unit, quantityGoal) = getGoalDetails(for: goal.title)
                
                let goalData: [String: Any] = [
                    "date": Timestamp(date: Date()),
                    "deleted": false,
                    "detail": goal.description,
                    "icon": goal.iconName,
                    "name": goal.title,
                    "quantityComplete": 0.0,
                    "quantityGoal": quantityGoal,
                    "unit": unit
                ]
                
                // Add more detailed error handling and logging
                do {
                    let docRef = try await goalsCollection.addDocument(data: goalData)
                    print("Successfully added goal: \(goal.title) with ID: \(docRef.documentID)")
                } catch {
                    print("Error adding goal \(goal.title): \(error.localizedDescription)")
                    throw error
                }
            }
        } catch {
            print("Failed to add goals: \(error.localizedDescription)")
            // Make sure to handle the failure state
            DispatchQueue.main.async {
                isProcessing = false
                // Optionally show an alert to the user
            }
        }
    }
    
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
                                TemplateGoalItem(goal: $templateGoals[index]) {
                                    if selectedGoals.contains(index) {
                                        selectedGoals.remove(index)
                                    } else {
                                        selectedGoals.insert(index)
                                    }
                                    print("Selected goals: \(selectedGoals)")
                                }
                                .padding(.vertical, 5)
                                .shadow(color: .blackShadow, radius: 20, y: 10)
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
                    
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .padding()
                    } else {
                        GradientButton(title: "Done", action: {
                            guard !selectedGoals.isEmpty else {
                                print("No goals selected")
                                return
                            }
                            
                            isProcessing = true
                            
                            // Update UI for selected goals
                            for index in selectedGoals {
                                templateGoals[index].checked = true
                            }
                            
                            Task {
                                do {
                                    await addSelectedGoalsToFirestore()
                                    // Only proceed if successful
                                    DispatchQueue.main.async {
                                        isProcessing = false
                                        done = true
                                    }
                                } catch {
                                    // Handle any errors
                                    DispatchQueue.main.async {
                                        isProcessing = false
                                        print("Failed to add goals: \(error.localizedDescription)")
                                        // Optionally show an alert to the user
                                    }
                                }
                            }
                        }, isEnabled: !isProcessing)
                        .padding()
                    }
                }
            }
            .navigationDestination(isPresented: $done) {
                ContentView()
            }
            .toolbarVisibility(.hidden)
            .sheet(isPresented: $showAddGoal) {
                AddGoalModal { newGoal in
                    templateGoals.append(newGoal)
                }
            }
        }
    }
}
#Preview {
    SelectTemplateGoalsView()
}
