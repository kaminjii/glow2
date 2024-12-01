import FirebaseFirestore
import FirebaseAuth

class ViewModel: ObservableObject {
    private let dailyLogRepository = DailyLogRepository()
    private let goalRepository = GoalRepository()
    @Published var isAuthenticated = false
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if user != nil {
                self?.setupDailyLogAndGoals()
            }
        }
    }
    
    func setupDailyLogAndGoals() {
        guard isAuthenticated else { return }
        
        dailyLogRepository.createDailyLog {
            self.goalRepository.createDailyGoals {
                print("Daily log and goals setup complete.")
            }
        }
    }
}
