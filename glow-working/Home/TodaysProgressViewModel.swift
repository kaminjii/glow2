import SwiftUI
import FirebaseCore

class TodaysProgressViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var isPickerPresented = false
    @Published var progress: CGFloat = 0.0
    
    private var repository = DailyLogRepository()
    
    func fetchTodayLog() {
        let today = Date()
        repository.fetchDailyLogs(for: today) { logs in
            if let fetchedLog = logs.first {
                self.note = fetchedLog.note ?? ""
                self.progress = CGFloat(fetchedLog.totalPercentCompleted)
            } else {
                self.note = ""
                self.progress = 0.0
                self.selectedImage = nil
            }
        }
    }
    
    func saveProgress() {
        let today = Date()
        
        // Check if a log already exists for today
        repository.fetchDailyLogs(for: today) { logs in
            if let existingLog = logs.first {
                // If a log exists, prepare to update it
                var updatedLogData = existingLog // Create a copy of the existing log
                updatedLogData.image = self.selectedImage != nil ? self.convertImageToData(self.selectedImage!) : "" // Convert UIImage to data if needed
                updatedLogData.note = self.note
                updatedLogData.totalPercentCompleted = Double(self.progress)
                
                // Update the existing log
                self.repository.updateDailyLog(updatedLogData) { success in
                    if success {
                        print("Log updated successfully!")
                    } else {
                        print("Failed to update log.")
                    }
                }
            } else {
                // If log does not exist, create a new one
                let logData = DailyLog(date: Timestamp(date: today), image: "", note: self.note, totalPercentCompleted: Double(self.progress))
                self.repository.addDailyLog(logData) { success in
                    if success {
                        print("Log added successfully!")
                    } else {
                        print("Failed to add log.")
                    }
                }
            }
        }
    }
    
    private func convertImageToData(_ image: UIImage) -> String {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            return imageData.base64EncodedString()
        }
        return ""
    }
}


