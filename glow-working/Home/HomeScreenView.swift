import SwiftUI
import FirebaseFirestore

struct HomeScreenView: View {
    @Binding var selectedTab: Int
    @State private var lastLogDate: Date? = UserDefaults.standard.object(forKey: "lastLogDate") as? Date

    @State private var editableGoals: [Goal] = []
    
    @State var note: String = ""
    @State private var selectedGoal: Goal? = nil
    @State private var showTodaysProgress = false
    @State private var totalProgress: CGFloat = 0.0

    @State private var goals: [Goal] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack {
                    homeScreenHeader
                    goalListScrollView
                        .edgesIgnoringSafeArea(.all)
                    
                    Spacer()
                    
                }
                .ignoresSafeArea(.all)
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .fullScreenCover(isPresented: $showTodaysProgress) {
                    TodaysProgressView(note: $note)
                }
                .sheet(item: $selectedGoal) { goal in
                    EditGoalProgressView(goal: .constant(goal)) {
                        fetchGoalsForToday()
                    }
                    .presentationDetents([.fraction(0.4), .large])
                }
                
                .onAppear {
                    fetchGoalsForToday()
                }
            }
        }

    }
    
    private var homeScreenHeader: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [backgroundColor, .whitePrimary]), startPoint: .top, endPoint: .bottom)
                .frame(maxHeight: 450)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Text("Hello Kaitlin!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle).bold()
                    .padding(.horizontal, 30)
                    .padding(.top, 100)
                    .padding(.bottom, 16)
                    .foregroundStyle(.white)
                
                Image(starImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                    .shadow(color: Color.black.opacity(0.20), radius: 5, y: 8)
                
                Button(action: {
                    showTodaysProgress = true
                }) {
                    todaysProgress
                        .padding()
                }
            }
        }
        .ignoresSafeArea()
        .frame(height: 450)
    }
    
    private var todaysProgress: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text("Today's Progress")
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .font(.title)
                        .foregroundStyle(.black1)
                    
                    Spacer()
                    
                    Text("\(Int(totalProgress * 100))%")
                        .font(.subheadline)
                        .foregroundStyle(.black1)
                        .frame(maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.bottom, 5)
                }
                .frame(height: 45)
                
                ProgressBar(progress: totalProgress)
            }
            .padding(.trailing)
            
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.black1)
                .frame(height: 75, alignment: .bottom)
                .padding(.bottom, 15)
        }
    }
    
    private var goalListScrollView: some View {
        return ScrollView {
            GoalsList(goals: $goals, onGoalSelected: { selectedGoal in
                self.selectedGoal = selectedGoal
            }, showValue: true)
            .padding(.top)

        }
    }
    
    private func fetchGoalsForToday() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Fetch goals for today
        Firestore.firestore().collection("goals")
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

    private func fetchDailyLogForToday() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        Firestore.firestore().collection("dailyLogs")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching daily log: \(error)")
                } else {
                    if let dailyLogDoc = querySnapshot?.documents.first {
                        let totalProgressValue = dailyLogDoc.data()["totalProgress"] as? Double ?? 0.0
                        
                        // Log the fetched total progress value
                        print("Fetched total progress value: \(totalProgressValue)")
                        
                        // Update the UI on the main thread
                        DispatchQueue.main.async {
                            self.totalProgress = CGFloat(totalProgressValue)
                            print("Updated total progress: \(self.totalProgress)") // Log the updated value
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
