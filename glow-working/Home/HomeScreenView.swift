import SwiftUI
import FirebaseFirestore

struct HomeScreenView: View {
    @Binding var selectedTab: Int
    @State var note: String = ""
    @State private var selectedGoal: Goal? = nil
    @State private var showTodaysProgress = false
    @State private var totalProgress: CGFloat = 0.0

    @State private var goals: [Goal] = []
    
    var body: some View {
        NavigationView {
            VStack {
                    homeScreenHeader
                    goalListScrollView

                    Spacer()
               
            }
            .ignoresSafeArea(.all)
            .background(Color.whitePrimary)
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
                .presentationDetents([.fraction(0.5), .large])
            }
            
            .onAppear {
                fetchGoalsForToday()
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
            VStack {
                GoalsList(goals: $goals) { selectedGoal in
                    self.selectedGoal = selectedGoal
                }
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            }

        }
        .padding()
    }
    
    private func fetchGoalsForToday() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        Firestore.firestore().collection("goals")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error)")
                } else {
                    self.goals = querySnapshot?.documents.compactMap { document -> Goal? in
                        try? document.data(as: Goal.self)
                    } ?? []
                    calculateTotalProgress()
                }
            }
    }
    
    private func calculateTotalProgress() {
        let totalGoals = goals.reduce(0) { $0 + $1.quantityGoal }
        let totalComplete = goals.reduce(0) { $0 + $1.quantityComplete }
        
        totalProgress = totalGoals > 0 ? totalComplete / totalGoals : 0
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
