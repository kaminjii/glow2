import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct StatsScreenView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Monthly Overview
                    MonthlyOverviewCard(monthlyProgress: viewModel.monthlyProgress)
                        .padding(.top, 20)
                    
                    // Streak Stats
                    StreakCard(
                        currentStreak: viewModel.currentStreak,
                        longestStreak: viewModel.longestStreak,
                        averageCompletion: viewModel.averageCompletion
                    )
                    
                    // Top Performing Goals
                    TopGoalsCard(topGoals: viewModel.topGoals)
                    
                    // Progress Over Time
                    WeeklyProgressCard(weeklyProgress: viewModel.weeklyProgress)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .padding(.top, 1)
            .background(Color.whitePrimary.edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.fetchStats()
            }
        }
    }
}

// MARK: - Monthly Overview Card
struct MonthlyOverviewCard: View {
    let monthlyProgress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Month Progress")
                    .font(.headline)
                    .foregroundStyle(.black1)
                Spacer()
                Text("\(Int(monthlyProgress * 100))%")
                    .font(.title2).bold()
                    .foregroundStyle(.blue1)
            }
            
            ProgressBar(progress: monthlyProgress)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let averageCompletion: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Streaks")
                .font(.headline)
                .foregroundStyle(.black1)
            
            HStack(spacing: 20) {
                StreakItem(
                    icon: "flame.fill",
                    title: "Current",
                    value: "\(currentStreak)",
                    subtitle: "days"
                )
                
                Divider()
                
                StreakItem(
                    icon: "trophy.fill",
                    title: "Best",
                    value: "\(longestStreak)",
                    subtitle: "days"
                )
                
                Divider()
                
                StreakItem(
                    icon: "chart.bar.fill",
                    title: "Average",
                    value: "\(Int(averageCompletion * 100))",
                    subtitle: "% complete"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
}

struct StreakItem: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue1)
                .font(.title3)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray1)
            
            Text(value)
                .font(.title3).bold()
                .foregroundStyle(.black1)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.gray1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Top Goals Card
struct TopGoalsCard: View {
    let topGoals: [(Goal, Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Goals")
                .font(.headline)
                .foregroundStyle(.black1)
            
            if topGoals.isEmpty {
                Text("Complete goals to see your stats")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(topGoals, id: \.0.id) { goal, completion in
                    HStack(spacing: 16) {
                        GradientIcon(iconName: goal.icon)
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.name)
                                .font(.subheadline)
                                .foregroundStyle(.black1)
                            
                            Text("\(Int(completion * 100))% completion rate")
                                .font(.caption)
                                .foregroundStyle(.gray1)
                        }
                        
                        Spacer()
                        
                        Image(starImage(for: completion))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
    
    private func starImage(for completion: Double) -> String {
        switch completion {
        case 0..<0.2: return "star5"
        case 0.2..<0.4: return "star4"
        case 0.4..<0.6: return "star3"
        case 0.6..<0.8: return "star2"
        case 0.8...1.0: return "star1"
        default: return "star5"
        }
    }
}

// MARK: - Weekly Progress Card
struct WeeklyProgressCard: View {
    let weeklyProgress: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundStyle(.black1)
            
            HStack(spacing: 16) {
                ForEach(Array(weeklyProgress.enumerated()), id: \.offset) { index, progress in
                    VStack(spacing: 8) {
                        Image(starImage(for: progress))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                        
                        Text(dayName(for: index))
                            .font(.caption2)
                            .foregroundStyle(.gray1)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
    
    private func dayName(for index: Int) -> String {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index]
    }
    
    private func starImage(for progress: Double) -> String {
        switch progress {
        case 0..<0.2: return "star5"
        case 0.2..<0.4: return "star4"
        case 0.4..<0.6: return "star3"
        case 0.6..<0.8: return "star2"
        case 0.8...1.0: return "star1"
        default: return "star5"
        }
    }
}

// MARK: - ViewModel
class StatsViewModel: ObservableObject {
    @Published var monthlyProgress: Double = 0.0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var averageCompletion: Double = 0.0
    @Published var topGoals: [(Goal, Double)] = []
    @Published var weeklyProgress: [Double] = Array(repeating: 0.0, count: 7)
    
    private let db = Firestore.firestore()
    
    func fetchStats() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Get current month's start and end dates
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth)!
        
        // Fetch daily logs for the month
        let dailyLogsRef = db.collection("users").document(userId).collection("dailyLogs")
        dailyLogsRef
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("date", isLessThan: Timestamp(date: startOfNextMonth))
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                // Calculate monthly progress
                let progress = documents.compactMap { try? $0.data(as: DailyLog.self) }
                self?.monthlyProgress = progress.isEmpty ? 0 :
                    progress.reduce(0) { $0 + $1.totalProgress } / Double(progress.count)
                
                // Calculate streaks and weekly progress
                self?.calculateStreaks(from: progress)
                self?.calculateWeeklyProgress(from: progress)
            }
        
        // Fetch goals and their completion rates
        let goalsRef = db.collection("users").document(userId).collection("goals")
        goalsRef
            .whereField("deleted", isEqualTo: false)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let goals = documents.compactMap { try? $0.data(as: Goal.self) }
                let goalsWithProgress = goals.map { goal -> (Goal, Double) in
                    let completion = Double(goal.quantityComplete) / Double(goal.quantityGoal)
                    return (goal, completion)
                }
                
                self?.topGoals = Array(goalsWithProgress
                    .sorted { $0.1 > $1.1 }
                    .prefix(3))
            }
    }
    
    private func calculateStreaks(from logs: [DailyLog]) {
        guard !logs.isEmpty else {
            currentStreak = 0
            longestStreak = 0
            averageCompletion = 0.0
            return
        }
        
        let calendar = Calendar.current
        let sortedLogs = logs.sorted { $0.date.dateValue() < $1.date.dateValue() }
        
        // Calculate average completion
        averageCompletion = logs.reduce(0.0) { $0 + $1.totalProgress } / Double(logs.count)
        
        // Get today's start
        let today = calendar.startOfDay(for: Date())
        
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var previousDate: Date? = nil
        
        // Process logs in reverse to find current streak first
        for log in sortedLogs.reversed() {
            let logDate = calendar.startOfDay(for: log.date.dateValue())
            
            // For current streak: must include today or yesterday
            if currentStreak == 0 {
                // Check if this log is from today or yesterday
                if logDate == today ||
                   logDate == calendar.date(byAdding: .day, value: -1, to: today) {
                    currentStreak = 1
                    previousDate = logDate
                    continue
                } else {
                    // If we didn't find today or yesterday, current streak is 0
                    break
                }
            }
            
            // Check if this date is consecutive with previous
            if let prev = previousDate,
               let daysBetween = calendar.dateComponents([.day], from: logDate, to: prev).day,
               daysBetween == 1 {
                currentStreak += 1
                previousDate = logDate
            } else {
                break
            }
        }
        
        // Reset for longest streak calculation
        previousDate = nil
        
        // Calculate longest streak by going through all logs
        for log in sortedLogs {
            let logDate = calendar.startOfDay(for: log.date.dateValue())
            
            if previousDate == nil {
                tempStreak = 1
                previousDate = logDate
                continue
            }
            
            if let prev = previousDate,
               let daysBetween = calendar.dateComponents([.day], from: prev, to: logDate).day {
                if daysBetween == 1 {
                    tempStreak += 1
                    longestStreak = max(longestStreak, tempStreak)
                } else {
                    tempStreak = 1
                }
                previousDate = logDate
            }
        }
        
        // Update final values
        self.currentStreak = currentStreak
        self.longestStreak = max(longestStreak, currentStreak)
    }
    
    private func calculateWeeklyProgress(from logs: [DailyLog]) {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the start of the current week (Sunday)
        let weekday = calendar.component(.weekday, from: today) - 1 // 0-based where 0 is Sunday
        guard let startOfWeek = calendar.date(byAdding: .day, value: -weekday, to: calendar.startOfDay(for: today)) else {
            return
        }
        
        // Reset array to empty
        weeklyProgress = Array(repeating: 0.0, count: 7)
        
        // Only fill in days up to today
        for dayOffset in 0...weekday {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek),
                  let log = logs.first(where: { calendar.isDate($0.date.dateValue(), inSameDayAs: date) }) else {
                continue
            }
            weeklyProgress[dayOffset] = log.totalProgress
        }
    }
}

#Preview {
    StatsScreenView(selectedTab: .constant(2))
}
