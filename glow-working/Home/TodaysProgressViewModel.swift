import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

// ViewModel responsible for managing the data and logic for TodaysProgressView
class TodaysProgressViewModel: ObservableObject {
    @Published var note: String = "" // Note text for today's progress
    @Published var isPickerPresented = false // Bool to control whether a picker is shown
    @Published var progress: CGFloat = 0.0 // Progress percentage represented as a CGFloat
    @Published var isLoading = false // Bool to manage loading state during network operations
    
    private var repository = DailyLogRepository() // Repository for interacting with the daily logs
    private var currentLogId: String? // The ID of the current log being worked with
    
    // Helper function to retrieve the current authenticated user's ID from Firebase Auth
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Function to save the user's progress for the day
    func saveProgress() {
        guard getCurrentUserId() != nil else {
            print("No authenticated user")
            return
        }
        
        isLoading = true // Set loading state while saving progress
        saveDailyLog(with: nil)  // Make sure to call this to save log
    }
    
    // Function to fetch today's progress log
    func fetchTodayLog() {
        guard getCurrentUserId() != nil else {
            print("No authenticated user")
            return
        }
        
        isLoading = true  // Set loading state
        
        let today = Date()
        repository.fetchDailyLogs(for: today) { [weak self] logs in
            guard let self = self else { return }
            
            if let fetchedLog = logs.first { // If a log is found for today, update state
                self.currentLogId = fetchedLog.id
                
                DispatchQueue.main.async {
                    self.note = fetchedLog.note ?? "" // Set the note from the fetched log
                    self.progress = CGFloat(fetchedLog.totalProgress) // Set the progress from the fetched log
                    self.isLoading = false  // Clear loading state
                }
            } else {
                DispatchQueue.main.async {
                    self.note = "" // Clear the note
                    self.progress = 0.0 // Reset progress
                    self.isLoading = false  // Clear loading state
                }
            }
        }
    }
    
    // function to save a daily log, either updating an existing one or adding a new one
    private func saveDailyLog(with imageUrl: String?) {
        let today = Date()
        
        // Fetch today's logs to check if an entry already exists for today
        repository.fetchDailyLogs(for: today) { [weak self] logs in
            guard let self = self else { return }
            
            if let existingLog = logs.first { // If a log for today exists, update it
                var updatedLogData = existingLog
                updatedLogData.note = self.note
                updatedLogData.totalProgress = Double(self.progress)
                
                // Update the log in the repository.
                self.repository.updateDailyLog(updatedLogData) { success in
                    DispatchQueue.main.async {
                        self.isLoading = false // Clear loading state after the operation
                        if success {
                            print("Log updated successfully!")
                        } else {
                            print("Failed to update log.")
                        }
                    }
                }
            } else { // If no log exists for today, create a new log
                let logData = DailyLog(
                    date: Timestamp(date: today),
                    image: "",
                    note: self.note,
                    totalProgress: Double(self.progress)
                )
                
                // Add the new log to the repository
                self.repository.addDailyLog(logData) { success in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if success {
                            print("Log added successfully!")
                        } else {
                            print("Failed to add log.")
                        }
                    }
                }
            }
        }
    }
}
