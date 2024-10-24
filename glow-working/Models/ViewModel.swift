import FirebaseFirestore

class ViewModel: ObservableObject {
    private let dailyLogRepository = DailyLogRepository()
    private let goalRepository = GoalRepository()

    func setupDailyLogAndGoals() {
        dailyLogRepository.createDailyLog {
            self.goalRepository.createDailyGoals {
                print("Daily log and goals setup complete.")
            }
        }
    }
}

