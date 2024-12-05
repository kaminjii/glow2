import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SelectTemplateGoalsView: View {
    @State private var done: Bool = false
    @State private var showAddGoal: Bool = false
    @State private var selectedGoals: Set<Int> = []
    @State private var isProcessing: Bool = false
    @State private var animate = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var customGoals: [TemplateGoal] = []
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    let templateGoals: [TemplateGoal] = [
        TemplateGoal(
            iconName: "figure.run",
            title: "Exercise",
            description: "Stay active and healthy with daily exercise",
            checked: false
        ),
        TemplateGoal(
            iconName: "book.fill",
            title: "Read",
            description: "Develop your mind through daily reading",
            checked: false
        ),
        TemplateGoal(
            iconName: "flame.fill",
            title: "Diet",
            description: "Maintain a balanced and healthy diet",
            checked: false
        ),
        TemplateGoal(
            iconName: "bed.double.fill",
            title: "Sleep",
            description: "Get quality sleep for better health",
            checked: false
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedStarField()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        welcomeSection
                        goalGrid
                        
                        // Custom goals grid
                        if !customGoals.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(customGoals.indices, id: \.self) { index in
                                    let adjustedIndex = templateGoals.count + index
                                    TemplateGoalCard(
                                        goal: customGoals[index],
                                        isSelected: selectedGoals.contains(adjustedIndex)
                                    ) {
                                        if selectedGoals.contains(adjustedIndex) {
                                            selectedGoals.remove(adjustedIndex)
                                        } else {
                                            selectedGoals.insert(adjustedIndex)
                                        }
                                    }
                                    .opacity(animate ? 1 : 0)
                                    .offset(y: animate ? 0 : 20)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        customGoalButton
                        Spacer(minLength: 60)
                    }
                }
                
                VStack {
                    Spacer()
                    continueButton
                }
            }
            .navigationDestination(isPresented: $done) {
                ContentView()
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddGoalModal { newGoal in
                // Add the new goal to customGoals array
                customGoals.append(newGoal)
                // Automatically select the new goal
                selectedGoals.insert(templateGoals.count + customGoals.count - 1)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0)) {
                animate = true
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image("glowLogoYellow")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .scaleEffect(animate ? 1 : 0.5)
            
            VStack(spacing: 8) {
                Text("Choose Your Goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                
                Text("Select the habits you want to track daily")
                    .font(.subheadline)
                    .foregroundColor(.gray1)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
            }
        }
        .padding(.top, 40)
    }
    
    private var goalGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(templateGoals.indices, id: \.self) { index in
                TemplateGoalCard(
                    goal: templateGoals[index],
                    isSelected: selectedGoals.contains(index)
                ) {
                    if selectedGoals.contains(index) {
                        selectedGoals.remove(index)
                    } else {
                        selectedGoals.insert(index)
                    }
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
            }
        }
        .padding(.horizontal)
    }
    
    private var customGoalButton: some View {
        Button(action: { showAddGoal = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Custom Goal")
            }
            .font(.headline)
            .foregroundColor(.blue1)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue1.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .opacity(animate ? 1 : 0)
    }
    
    private var continueButton: some View {
        VStack {
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.2)
            } else {
                GradientButton(
                    title: "Continue",
                    action: handleContinue,
                    isEnabled: !isProcessing
                )
            }
        }
        .padding()
        .background(.whitePrimary)
    }
    
    private func handleContinue() {
        guard !selectedGoals.isEmpty else {
            errorMessage = "Please select at least one goal"
            showError = true
            return
        }
        
        isProcessing = true
        Task {
            do {
                try await addSelectedGoalsToFirestore()
                DispatchQueue.main.async {
                    isProcessing = false
                    done = true
                }
            } catch {
                DispatchQueue.main.async {
                    isProcessing = false
                    errorMessage = "Failed to save goals. Please try again."
                    showError = true
                }
            }
        }
    }
    
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
    
    private func addSelectedGoalsToFirestore() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"])
        }
        
        let db = Firestore.firestore()
        let goalsCollection = db.collection("users").document(userId).collection("goals")
        
        for index in selectedGoals {
            let goal: TemplateGoal
            if index < templateGoals.count {
                goal = templateGoals[index]
            } else {
                let customIndex = index - templateGoals.count
                goal = customGoals[customIndex]
            }
            
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
            
            _ = try await goalsCollection.addDocument(data: goalData)
        }
        
        await viewModel.completeOnboarding()
    }
}

struct TemplateGoalCard: View {
    let goal: TemplateGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goal.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue1)
                
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray1)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue1 : Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
    }
}

#Preview {
    SelectTemplateGoalsView()
        .environmentObject(AuthenticationViewModel())
}
