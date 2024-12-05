import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class TodaysProgressViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var isPickerPresented = false
    @Published var progress: CGFloat = 0.0
    @Published var isLoading = false
    
    private var repository = DailyLogRepository()
    private var currentLogId: String?
    
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func saveProgress() {
        guard getCurrentUserId() != nil else {
            print("No authenticated user")
            return
        }
        
        isLoading = true
        saveDailyLog(with: nil)  // Make sure to call this
    }
    
    func fetchTodayLog() {
        guard getCurrentUserId() != nil else {
            print("No authenticated user")
            return
        }
        
        isLoading = true  // Set loading state
        
        let today = Date()
        repository.fetchDailyLogs(for: today) { [weak self] logs in
            guard let self = self else { return }
            
            if let fetchedLog = logs.first {
                self.currentLogId = fetchedLog.id
                
                DispatchQueue.main.async {
                    self.note = fetchedLog.note ?? ""
                    self.progress = CGFloat(fetchedLog.totalProgress)
                    self.isLoading = false  // Clear loading state
                }
            } else {
                DispatchQueue.main.async {
                    self.note = ""
                    self.progress = 0.0
                    self.isLoading = false  // Clear loading state
                }
            }
        }
    }
    
    private func saveDailyLog(with imageUrl: String?) {
        let today = Date()
        
        repository.fetchDailyLogs(for: today) { [weak self] logs in
            guard let self = self else { return }
            
            if let existingLog = logs.first {
                var updatedLogData = existingLog
                updatedLogData.note = self.note
                updatedLogData.totalProgress = Double(self.progress)
                
                self.repository.updateDailyLog(updatedLogData) { success in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if success {
                            print("Log updated successfully!")
                        } else {
                            print("Failed to update log.")
                        }
                    }
                }
            } else {
                let logData = DailyLog(
                    date: Timestamp(date: today),
                    image: "",
                    note: self.note,
                    totalProgress: Double(self.progress)
                )
                
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
