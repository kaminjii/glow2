import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GoalsView: View {
    @Binding var selectedTab: Int
    @StateObject private var goalRepository = GoalRepository()
    @State private var goals: [Goal] = []
    @State private var selectedGoal: Goal? = nil
    @State private var showActionSheet = false
    @State private var showDeleteAlert = false
    @State private var showAddGoal = false
    @State private var showEditGoal = false
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Goals")
                            .font(.title3).bold()
                            .foregroundStyle(.black1)
                        
                        Spacer()
                        
                        Button(action: { showAddGoal = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue1)
                        }
                    }
                    .padding()
                    .padding(.top, 60)
                    .background(Color.whitePrimary)
                    
                    if goals.isEmpty {
                       emptyStateView
                   } else {
                       ScrollView {
                           GoalsList(
                               goals: $goals,
                               onGoalSelected: { goal in
                                   selectedGoal = goal
                                   showActionSheet = true
                               },
                               showValue: false
                           )
                       }
                   }
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            ManageGoalView()
                .onDisappear { fetchGoalsForToday() }
        }
        .sheet(isPresented: $showEditGoal) {
            if let goal = selectedGoal {
                ManageGoalView(isEditing: true, goal: goal)
                    .onDisappear { fetchGoalsForToday() }
            }
        }
        .confirmationDialog("Goal Options", isPresented: $showActionSheet, titleVisibility: .hidden) {
            Button("Edit Goal") {
                showEditGoal = true
            }
            Button("Delete Goal", role: .destructive) {
                showDeleteAlert = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete Goal", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let goal = selectedGoal {
                    deleteGoal(goal)
                }
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
        .onAppear {
            fetchGoalsForToday()
        }
    }
    
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
                    .cornerRadius(25)
            }
            .padding(.top)
        }
        .frame(maxHeight: .infinity)
    }
    
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
    
    private func deleteGoal(_ goal: Goal) {
        guard let userId = Auth.auth().currentUser?.uid,
              let goalId = goal.id else { return }
        
        db.collection("users").document(userId).collection("goals")
            .document(goalId)
            .updateData(["deleted": true]) { error in
                if error == nil {
                    fetchGoalsForToday()
                }
            }
    }
}

struct GoalCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: goal.icon)
                            .foregroundStyle(.black1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(.black1)
                    
                    if let detail = goal.detail {
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.gray1)
                    }
                    
                    Text("\(Int((goal.quantityComplete / goal.quantityGoal) * 100))% Complete")
                        .font(.caption)
                        .foregroundStyle(.gray1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray3)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .blackShadow, radius: 10, y: 5)
        }
    }
}

#Preview {
    GoalsView(selectedTab: .constant(3))
}


#Preview {
    GoalsView(selectedTab: .constant(3))
}
