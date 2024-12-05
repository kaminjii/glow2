import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// The main view where users can select goals from a predefined list or add their own custom goals.
struct SelectTemplateGoalsView: View {
    // State variables for managing the view's UI and logic.
    @State private var done: Bool = false // To navigate to the next view when the process is complete.
    @State private var showAddGoal: Bool = false // To show the modal for adding a custom goal.
    @State private var selectedGoals: Set<Int> = [] // To keep track of selected goal indices.
    @State private var isProcessing: Bool = false // To indicate processing state.
    @State private var animate = false // For animation control.
    @State private var showError = false // To show an error alert.
    @State private var errorMessage = "" // The message to display in case of an error.
    @State private var customGoals: [TemplateGoal] = [] // Array to store custom user-added goals.
    
    // Injecting the AuthenticationViewModel for managing authentication state.
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    // Sample predefined template goals for the user to choose from.
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
                // Background animation view.
                AnimatedStarField()
                
                // ScrollView to display the content.
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        welcomeSection // Welcome section with title and description.
                        goalGrid // Grid of predefined template goals.
                        
                        // Custom goals grid, displayed if there are custom goals.
                        if !customGoals.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(customGoals.indices, id: \.self) { index in
                                    let adjustedIndex = templateGoals.count + index // Adjusted index for custom goals.
                                    TemplateGoalCard(
                                        goal: customGoals[index],
                                        isSelected: selectedGoals.contains(adjustedIndex)
                                    ) {
                                        // Toggle the selection state of the custom goal.
                                        if selectedGoals.contains(adjustedIndex) {
                                            selectedGoals.remove(adjustedIndex)
                                        } else {
                                            selectedGoals.insert(adjustedIndex)
                                        }
                                    }
                                    .opacity(animate ? 1 : 0) // Animation effect for custom goals.
                                    .offset(y: animate ? 0 : 20) // Animation effect for custom goals.
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        customGoalButton // Button to add a custom goal.
                        Spacer(minLength: 60) // Spacer to separate content and continue button.
                    }
                }
                
                // Continue button section, which is displayed at the bottom of the screen.
                VStack {
                    Spacer()
                    continueButton
                }
            }
            .navigationDestination(isPresented: $done) {
                ContentView() // Navigate to the next view when done.
            }
        }
        // Modal sheet for adding custom goals.
        .sheet(isPresented: $showAddGoal) {
            AddGoalModal { newGoal in
                // Add the new goal to the customGoals array and automatically select it.
                customGoals.append(newGoal)
                selectedGoals.insert(templateGoals.count + customGoals.count - 1)
            }
        }
        // Alert for displaying errors.
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        // Animation trigger when the view appears.
        .onAppear {
            withAnimation(.spring(duration: 1.0)) {
                animate = true
            }
        }
    }
    
    // View for the welcome section with logo and introductory text.
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image("glowLogoYellow")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .scaleEffect(animate ? 1 : 0.5) // Animation for logo.
            
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
    
    // View for displaying the grid of predefined template goals.
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
                    // Toggle the selection state of the template goal.
                    if selectedGoals.contains(index) {
                        selectedGoals.remove(index)
                    } else {
                        selectedGoals.insert(index)
                    }
                }
                .opacity(animate ? 1 : 0) // Animation effect for template goals.
                .offset(y: animate ? 0 : 20) // Animation effect for template goals.
            }
        }
        .padding(.horizontal)
    }
    
    // View for the button to add a custom goal.
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
        .opacity(animate ? 1 : 0) // Animation effect for custom goal button.
    }
    
    // View for the continue button at the bottom.
    private var continueButton: some View {
        VStack {
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.2) // Scaling effect for the progress view.
            } else {
                GradientButton(
                    title: "Continue",
                    action: handleContinue,
                    isEnabled: !isProcessing
                )
            }
        }
        .padding()
        .background(.whitePrimary) // Background color for the button.
    }
    
    // Function to handle the continue button action.
    private func handleContinue() {
        // Ensure that at least one goal is selected before proceeding.
        guard !selectedGoals.isEmpty else {
            errorMessage = "Please select at least one goal"
            showError = true
            return
        }
        
        isProcessing = true // Indicate that processing is in progress.
        Task {
            do {
                // Attempt to add selected goals to Firestore.
                try await addSelectedGoalsToFirestore()
                DispatchQueue.main.async {
                    isProcessing = false
                    done = true // Navigate to the next view upon success.
                }
            } catch {
                // Handle any errors during the Firestore operation.
                DispatchQueue.main.async {
                    isProcessing = false
                    errorMessage = "Failed to save goals. Please try again."
                    showError = true
                }
            }
        }
    }
    
    // Function to get the details for a specific goal based on its title.
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
    
    // Function to add selected goals to Firestore.
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
                goal = customGoals[index - templateGoals.count]
            }
            
            // Store each selected goal in Firestore.
            let goalDetails = getGoalDetails(for: goal.title)
            let data: [String: Any] = [
                "title": goal.title,
                "iconName": goal.iconName,
                "unit": goalDetails.unit,
                "quantityGoal": goalDetails.quantityGoal,
                "createdAt": Timestamp(date: Date())
            ]
            
            try await goalsCollection.addDocument(data: data)
        }
    }
}

#Preview {
    SelectTemplateGoalsView()
        .environmentObject(AuthenticationViewModel())
}
