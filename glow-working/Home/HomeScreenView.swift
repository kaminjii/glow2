import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Home view serves as the main screen for the app's home interface
struct HomeScreenView: View {
    @Binding var selectedTab: Int // Binding to track the selected tab in the tab bar
    @State private var lastLogDate: Date? = UserDefaults.standard.object(forKey: "lastLogDate") as? Date // Stores the last logged date
    @State private var editableGoals: [Goal] = [] // Goals that can be edited by the user
    @State var note: String = "" // Note for today's progress, editable by the user
    @State private var selectedGoal: Goal? = nil // Tracks the goal currently selected for editing
    @State private var showTodaysProgress = false // Boolean to toggle the display of today's progress sheet
    @State private var totalProgress: CGFloat = 0.0 // The user's total progress for the day, as a percentage
    @State private var goals: [Goal] = [] // Goals for the current day
    @State private var userName: String = "" // User's name, fetched from Firestore
    @StateObject private var viewModel = ViewModel() // ViewModel for additional logic or state management
    @State private var starOffset: CGFloat = 0 // Offset for the animated star section
    @StateObject private var goalRepository = GoalRepository() // Manages goal-related data operations
    
    private let db = Firestore.firestore()  // Firestore instance for database operations
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all) // Sets the background color
                
                VStack(spacing: 0) {
                    headerGradient // Gradient section at the top
                    Spacer()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 10) {
                            welcomeSection // Displays a greeting with the user's name
                            starSection  // Animated star section for visual appeal
                                .padding(.vertical)
                            progressSection // Displays today's progress with a button to show details
                            goalsList // Lists the goals for the day
                            Spacer(minLength: 40)
                        }
                    }
                    .padding(.top, 1)
                }
                .tabItem {
                    Image(systemName: "house.fill") // Tab bar item icon for the home screen
                }
            }
            .sheet(isPresented: $showTodaysProgress) {
                TodaysProgressView(note: $note) // Shows today's progress in a sheet
                    .presentationDetents([.fraction(0.6), .large]) // Configures the sheet size
            }
            .sheet(item: $selectedGoal) { goal in
                EditGoalProgressView(goal: .constant(goal)) {
                    fetchGoalsForToday() // Fetch updated goals after editing
                }
                .presentationDetents([.fraction(0.5), .large])
            }
            .onAppear {
                fetchUserName() // Fetch the user's name from Firestore
                // First create daily goals if needed, then fetch them
                goalRepository.createDailyGoals { success in
                    if success {
                        fetchGoalsForToday()
                    }
                }
                withAnimation(.easeInOut(duration: 2).repeatForever()) {
                    starOffset = -20
                }
            }
        }
    }
    
    // MARK: components
    
    // Header section with a gradient background
    private var headerGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [backgroundColor, .whitePrimary]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 500)
    }
    
    // Welcome section displaying a greeting with the user's name
    private var welcomeSection: some View {
        Text("Hello \(userName)!")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle).bold()
            .padding(.horizontal, 30)
            .foregroundStyle(.white)
    }
    
    // Animated star section
    private var starSection: some View {
        Image(starImage)
            .resizable()
            .scaledToFit()
            .frame(width: 280, height: 280)
            .shadow(color: Color.black.opacity(0.20), radius: 5, y: 8)
            .offset(y: starOffset)
    }
    
    // Progress section with a button to view today's progress details
    private var progressSection: some View {
        Button(action: {
            showTodaysProgress = true
        }) {
            VStack(spacing: 0) {
                HStack {
                    Text("Today's Progress")
                        .font(.title3.bold())
                        .foregroundStyle(.black1)
                    
                    Spacer()
                    
                    Text("\(Int(totalProgress * 100))%") // Display progress as a percentage
                        .font(.subheadline)
                        .foregroundStyle(.black1)
                }
                .padding(.bottom, 12)
                
                ProgressBar(progress: totalProgress) // Circular progress bar
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .blackShadow, radius: 10, y: 5)
            )
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    // List of daily goals, with the ability to select a goal for editing
    private var goalsList: some View {
        GoalsList(goals: $goals, onGoalSelected: { selectedGoal in
            self.selectedGoal = selectedGoal
        }, showValue: true)
    }
    
    // MARK: helper functions
    
    // Fetch user name from Firestore
    private func fetchUserName() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }
            
            if let document = document, document.exists {
                userName = document.data()?["fullName"] as? String ?? ""
            }
            
            print(userName)
        }
    }
    
    // Fetch goals for the current day
    private func fetchGoalsForToday() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch goals for today from user's subcollection
        db.collection("users").document(userId).collection("goals")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("deleted", isEqualTo: false)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error)")
                } else {
                    self.goals = querySnapshot?.documents.compactMap { document -> Goal? in
                        try? document.data(as: Goal.self)
                    } ?? []
                    
                    self.fetchDailyLogForToday()
                }
            }
    }
    
    // Fetch progress for the current day
    private func fetchDailyLogForToday() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch daily log from user's subcollection
        db.collection("users").document(userId).collection("dailyLogs")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching daily log: \(error)")
                } else {
                    if let dailyLogDoc = querySnapshot?.documents.first {
                        let totalProgressValue = dailyLogDoc.data()["totalProgress"] as? Double ?? 0.0
                        
                        print("Fetched total progress value: \(totalProgressValue)")
                        
                        DispatchQueue.main.async {
                            self.totalProgress = CGFloat(totalProgressValue)
                            print("Updated total progress: \(self.totalProgress)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.totalProgress = 0.0
                            print("No daily log found, set total progress to 0.")
                        }
                    }
                }
            }
    }
    
    // Star image based on progress
    private var starImage: String {
        switch totalProgress {
        case 0..<0.2:
            return "star5"
        case 0.2..<0.4:
            return "star4"
        case 0.4..<0.6:
            return "star3"
        case 0.6..<0.8:
            return "star2"
        case 0.8...1.0:
            return "star1"
        default:
            return "star3"
        }
    }
    
    // Background color based on progress
    private var backgroundColor: Color {
        switch totalProgress {
        case 0..<0.2:
            return .bottomBlue
        case 0.2..<0.4:
            return .middleBlue
        case 0.4..<0.6:
            return .middleBrown
        case 0.6..<0.8:
            return .middleYellow
        case 0.8...1.0:
            return .topYellow
        default:
            return .middleBrown
        }
    }
}

#Preview {
    HomeScreenView(selectedTab: .constant(0))
}
