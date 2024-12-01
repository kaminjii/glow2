import SwiftUI
import FirebaseCore
import FirebaseAuth

class TodaysProgressViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var isPickerPresented = false
    @Published var progress: CGFloat = 0.0
    
    private var repository = DailyLogRepository()
    
    // Add user check helper
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func fetchTodayLog() {
        guard getCurrentUserId() != nil else {
            print("No authenticated user")
            return
        }
        
        let today = Date()
        repository.fetchDailyLogs(for: today) { [weak self] logs in
            guard let self = self else { return }
            
            if let fetchedLog = logs.first {
                DispatchQueue.main.async {
                    self.note = fetchedLog.note ?? ""
                    self.progress = CGFloat(fetchedLog.totalProgress)
                    
                    // Handle image if it exists
                    if let imageString = fetchedLog.image, !imageString.isEmpty {
                        if let imageData = Data(base64Encoded: imageString),
                           let image = UIImage(data: imageData) {
                            self.selectedImage = image
                        }
                    } else {
                        self.selectedImage = nil
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.note = ""
                    self.progress = 0.0
                    self.selectedImage = nil
                }
            }
        }
    }
    
    func saveProgress() {
        guard getCurrentUserId() != nil else {
            print("No authenticated user")
            return
        }
        
        let today = Date()
        
        // Check if a log already exists for today
        repository.fetchDailyLogs(for: today) { [weak self] logs in
            guard let self = self else { return }
            
            if let existingLog = logs.first {
                // If a log exists, prepare to update it
                var updatedLogData = existingLog
                
                // Convert image to base64 string if it exists
                if let image = self.selectedImage {
                    updatedLogData.image = self.convertImageToData(image)
                }
                
                updatedLogData.note = self.note
                updatedLogData.totalProgress = Double(self.progress)
                
                // Update the existing log
                self.repository.updateDailyLog(updatedLogData) { success in
                    DispatchQueue.main.async {
                        if success {
                            print("Log updated successfully!")
                        } else {
                            print("Failed to update log.")
                        }
                    }
                }
            } else {
                // If log does not exist, create a new one
                let imageString = self.selectedImage != nil ? self.convertImageToData(self.selectedImage!) : ""
                let logData = DailyLog(
                    date: Timestamp(date: today),
                    image: imageString,
                    note: self.note,
                    totalProgress: Double(self.progress)
                )
                
                self.repository.addDailyLog(logData) { success in
                    DispatchQueue.main.async {
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
    
    private func convertImageToData(_ image: UIImage) -> String {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            return imageData.base64EncodedString()
        }
        return ""
    }
}
