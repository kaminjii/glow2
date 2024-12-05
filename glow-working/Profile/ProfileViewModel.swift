import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showEditProfile = false
    @Published var showChangePassword = false
    
    // MARK: - Dependencies
    private let userManager: UserManager
    private let statsManager: StatsManager
    private let achievementManager: AchievementManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var fullName: String {
        get { userManager.fullName }
        set { userManager.fullName = newValue }
    }
    
    var email: String {
        get { userManager.email }
        set { userManager.email = newValue }
    }
    
    var recordedDays: Int {
        statsManager.recordedDays
    }
    
    var streak: Int {
        statsManager.streak
    }
    
    var achievements: [Achievement] {
        achievementManager.achievements
    }
    
    var showReauthDialog: Bool {
        get { userManager.showReauthDialog }
        set { userManager.showReauthDialog = newValue }
    }
    
    var deleteError: String? {
        userManager.deleteError
    }
    
    var reauthPassword: String {
        get { userManager.reauthPassword }
        set { userManager.reauthPassword = newValue }
    }
    
    var isProcessingDelete: Bool {
        userManager.isProcessingDelete
    }
    
    var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalAchievements: Int {
        AchievementManager.achievements.count
    }
    
    var starImage: String {
        "star3"
    }
    
    // MARK: - Initialization
    init(userManager: UserManager = .init(),
         statsManager: StatsManager = .init(),
         achievementManager: AchievementManager = .init()) {
        self.userManager = userManager
        self.statsManager = statsManager
        self.achievementManager = achievementManager
        
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Setup any necessary publisher/subscriber relationships between managers
        userManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        statsManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        achievementManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        userManager.loadUserData()
        achievementManager.loadAchievements()
        statsManager.calculateStats()
    }
    
    // MARK: - Public Methods
    
    /// Updates user profile information
    func updateProfile() async {
        do {
            try await userManager.updateProfile(fullName: fullName, email: email)
        } catch {
            print("Error updating profile: \(error)")
        }
    }
    
    /// Updates user password
    func updatePassword(currentPassword: String, newPassword: String) async {
        do {
            try await userManager.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
        } catch {
            print("Error updating password: \(error)")
        }
    }
    
    /// Initiates account deletion process
    func deleteAccount() {
        userManager.deleteAccount()
    }
    
    /// Confirms account deletion with password
    func confirmDeleteAccount(password: String) async -> Bool {
        await userManager.confirmDeleteAccount(password: password)
    }
    
    /// Refreshes achievement data
    func refreshAchievements() {
        achievementManager.refreshAchievements()
    }
    
    /// Resets the delete account state
    func resetDeleteAccountState() {
        userManager.resetDeleteAccountState()
    }
}
