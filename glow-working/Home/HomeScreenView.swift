import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomeScreenView: View {
    @Binding var selectedTab: Int
    @State private var lastLogDate: Date? = UserDefaults.standard.object(forKey: "lastLogDate") as? Date
    @State private var editableGoals: [Goal] = []
    @State var note: String = ""
    @State private var selectedGoal: Goal? = nil
    @State private var showTodaysProgress = false
    @State private var totalProgress: CGFloat = 0.0
    @State private var goals: [Goal] = []
    @State private var userName: String = ""
    @StateObject private var viewModel = ViewModel()
    @State private var starOffset: CGFloat = 0
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    headerGradient
                    Spacer()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 10) {
                            welcomeSection
                            starSection
                                .padding(.vertical)
                            progressSection
                            goalsList
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "house.fill")
                }
            }
            .fullScreenCover(isPresented: $showTodaysProgress) {
                TodaysProgressView(note: $note)
            }
            .sheet(item: $selectedGoal) { goal in
                EditGoalProgressView(goal: .constant(goal)) {
                    fetchGoalsForToday()
                }
                .presentationDetents([.fraction(0.5), .large])
            }
            .onAppear {
                viewModel.setupDailyLogAndGoals()
                fetchUserName()
                fetchGoalsForToday()
                withAnimation(.easeInOut(duration: 2).repeatForever()) {
                    starOffset = -20
                }
            }
        }
    }
    
// MARK: components
    
    private var headerGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [backgroundColor, .whitePrimary]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 500)
    }
    
    private var welcomeSection: some View {
        Text("Hello \(userName)!")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle).bold()
            .padding(.horizontal, 30)
            .foregroundStyle(.white)
    }
    
    private var starSection: some View {
        Image(starImage)
            .resizable()
            .scaledToFit()
            .frame(width: 280, height: 280)
            .shadow(color: Color.black.opacity(0.20), radius: 5, y: 8)
            .offset(y: starOffset)
    }
    
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
                    
                    Text("\(Int(totalProgress * 100))%")
                        .font(.subheadline)
                        .foregroundStyle(.black1)
                }
                .padding(.bottom, 12)
                
                ProgressBar(progress: totalProgress)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .blackShadow, radius: 10, y: 5)
            )
            .padding(.horizontal)
        }
    }
    
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
