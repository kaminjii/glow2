import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// A view for displaying a goal card with options to edit or delete.
struct GoalCard: View {
    let goal: Goal  // The goal data to display.
    let onEdit: () -> Void  // Callback for when the edit button is tapped.
    let onDelete: () -> Void  // Callback for when the delete button is tapped.
    
    var body: some View {
        HStack {
            // Display a gradient icon for the goal.
            GradientIcon(iconName: goal.icon)
            
            // VStack to display the goal's name and details.
            VStack(alignment: .leading, spacing: 0) {
                Text(goal.name)
                    .font(.headline)
                    .foregroundStyle(.black1)  // Custom color for text.
                Text(goal.detail ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray1)  // Gray color for details.
            }
            .padding(.horizontal, 10)
            
            Spacer()
            
            // Menu for options (Edit and Delete) with a button trigger.
            Menu {
                Button("Edit", action: onEdit)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.gray1)
            }
            .frame(height: 50)
        }
        .padding()
        .background(Color.white)  // Background color of the card.
        .cornerRadius(16)  // Rounded corners for the card.
        .shadow(color: .blackShadow, radius: 10, y: 5)  // Shadow effect.
    }
}

// Main view for displaying and managing goals.
struct GoalsView: View {
    @Binding var selectedTab: Int  // The tab selected in the parent view.
    @StateObject private var goalRepository = GoalRepository()  // A repository for managing goal data.
    @State private var goals: [Goal] = []  // Array to hold the goals.
    @State private var selectedGoal: Goal? = nil  // The goal selected for editing or deleting.
    @State private var showDeleteAlert = false  // Boolean to control showing the delete confirmation alert.
    @State private var showAddGoal = false  // Boolean to control showing the add goal view.
    @State private var showEditGoal = false  // Boolean to control showing the edit goal view.
    
    private let db = Firestore.firestore()  // Firestore database reference.
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)  // Background color for the view.
                
                VStack(spacing: 0) {
                    // Header section with the title and an "Add Goal" button.
                    HStack {
                        Text("Goals")
                            .font(.title3).bold()
                            .foregroundStyle(.black1)
                        
                        Spacer()
                        
                        Button(action: { showAddGoal = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue1)  // Color for the "Add" button.
                        }
                    }
                    .padding()
                    .background(Color.whitePrimary)
                    
                    // Show an empty state view if there are no goals.
                    if goals.isEmpty {
                        emptyStateView
                    } else {
                        // Scroll view for displaying the list of goals.
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(goals) { goal in
                                    GoalCard(
                                        goal: goal,
                                        onEdit: {
                                            selectedGoal = goal  // Set the selected goal for editing.
                                            showEditGoal = true  // Show the edit goal view.
                                        },
                                        onDelete: {
                                            selectedGoal = goal  // Set the selected goal for deletion.
                                            showDeleteAlert = true  // Show the delete alert.
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            // Display the "ManageGoalView" for adding a new goal.
            ManageGoalView()
                .onDisappear { fetchGoalsForToday() }  // Refresh the goals when the view disappears.
        }
        .sheet(isPresented: $showEditGoal) {
            // Display the "ManageGoalView" for editing the selected goal.
            if let goal = selectedGoal {
                ManageGoalView(isEditing: true, goal: goal)
                    .onDisappear { fetchGoalsForToday() }  // Refresh the goals when the view disappears.
            }
        }
        .alert("Delete Goal", isPresented: $showDeleteAlert) {
            // Show a confirmation alert for deleting a goal.
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let goal = selectedGoal {
                    deleteGoal(goal)  // Delete the selected goal.
                }
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
        .onAppear {
            fetchGoalsForToday()  // Fetch goals when the view appears.
        }
    }
    
    // View shown when there are no goals in the list.
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundStyle(.gray3)
            
            Text("No Goals Added")
                .font(.title3)
                .foregroundStyle(.gray1)
            
            Text("Add your first goal to start tracking your progress")
                .font(.subheadline)
                .foregroundStyle(.gray1)
                .multilineTextAlignment(.center)
            
            Button(action: { showAddGoal = true }) {
                Text("Add Goal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            colors: [.blueGradientStart, .blueGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)  // Rounded corners for the button.
            }
            .padding(.top)
        }
        .frame(maxHeight: .infinity)
    }
    
    // Fetch the goals for today from Firestore.
    private func fetchGoalsForToday() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        db.collection("users").document(userId).collection("goals")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: today))
            .whereField("date", isLessThan: Timestamp(date: tomorrow))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { snapshot, error in
                self.goals = snapshot?.documents.compactMap { try? $0.data(as: Goal.self) } ?? []
            }
    }
    
    // Mark a goal as deleted in Firestore.
    private func deleteGoal(_ goal: Goal) {
        guard let userId = Auth.auth().currentUser?.uid,
              let goalId = goal.id else { return }
        
        db.collection("users").document(userId).collection("goals")
            .document(goalId)
            .updateData(["deleted": true]) { error in
                if error == nil {
                    fetchGoalsForToday()  // Refresh the goals after deletion.
                }
            }
    }
}

#Preview {
    GoalsView(selectedTab: .constant(3))
}
