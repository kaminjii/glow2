import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct EditExistingDayView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dailyLogRepository = DailyLogRepository()
    @StateObject private var goalRepository = GoalRepository()
    private let db = Firestore.firestore()

    @State private var dailyLog: DailyLog?
    @State private var selectedGoal: Goal? = nil
    @State private var note: String = ""
    @State private var originalNote: String = ""
    @State private var goals: [Goal] = []
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var progress: Double = 0
    @State private var isLoading = false
    
    let date: Date
    var onSave: (DailyLog) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                // Main content view when data is loaded
                if dailyLog != nil {
                    ScrollView {
                        VStack(spacing: 24) {
                            progressCard
                            goalsList
                            noteSection
                            Spacer(minLength: 40)
                        }
                    }
                } else {
                    // Loading state while fetching data
                    ProgressView("Loading...")
                        .onAppear {
                            fetchDailyLog(for: date)
                            goalRepository.fetchGoals(for: date)
                        }
                }
                
                // Global loading overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Navigation bar items
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .principal) {
                    if let dailyLog = dailyLog {
                        Text(formattedDate(for: dailyLog.date.dateValue()))
                            .font(.headline)
                    }
                }
            }
        }
        // Modal sheets for goal editing and photo selection
        .sheet(item: $selectedGoal) { goal in
            EditGoalProgressView(goal: .constant(goal)) {
                fetchDailyLog(for: date)
                goalRepository.fetchGoals(for: date)
            }
            .presentationDetents([.fraction(0.5), .large])
        }
        // Update goals when repository data changes
        .onReceive(goalRepository.$goals) { fetchedGoals in
            self.goals = fetchedGoals
        }
    }
    
    // View component for displaying overall progress
    private var progressCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overall Progress")
                    .font(.headline)
                    .foregroundStyle(.black1)
                
                HStack {
                    ProgressBar(progress: progress)
                    Text("\(Int(progress * 100))%")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray1)
                        .frame(width: 50)
                }
            }
            
            Divider()
            
            Text("Complete your daily goals to increase your overall progress")
                .font(.subheadline)
                .foregroundStyle(.gray1)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
        .padding()
    }
    
    // View component for displaying the list of goals
    private var goalsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(.headline)
                .foregroundStyle(.black1)
                .padding(.horizontal)
            
            GoalsList(goals: $goals, onGoalSelected: { selectedGoal in
                self.selectedGoal = selectedGoal
            }, showValue: true)
        }
    }
    
    // View component for the notes input section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .foregroundStyle(.black1)
            
            NoteTextEditor(note: $note, originalNote: $originalNote)
                .frame(minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .blackShadow, radius: 10, y: 5)
                )
        }
        .padding()
    }
    
    // MARK: - Helper Functions
        
    // Initiates the save process with loading state
    private func saveChanges() {
        guard let dailyLog = dailyLog else { return }
        
        isLoading = true
        saveDailyLogChanges(dailyLog)
    }

    // Updates the daily log in Firebase
    private func saveDailyLogChanges(_ dailyLog: DailyLog) {
        var updatedLog = dailyLog
        
        // Update note if changed
        if note != originalNote {
            updatedLog.note = note
        }
        
        // Call the onSave callback
        onSave(updatedLog)
        
        // Update in Firestore
        dailyLogRepository.updateDailyLog(updatedLog) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    print("Daily log updated successfully")
                    // Update goals after successful log update
                    for goal in goalRepository.goals {
                        updateGoal(goal)
                    }
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("Failed to update daily log")
                }
            }
        }
    }
    
    // Formats the date for display in the navigation bar
    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    // Updates a single goal in the repository
    private func updateGoal(_ updatedGoal: Goal) {
        goalRepository.updateGoal(updatedGoal)
    }

    // Fetches the daily log for the specified date
    private func fetchDailyLog(for date: Date) {
        dailyLogRepository.fetchDailyLogs(for: date) { logs in
            if let log = logs.first {
                self.dailyLog = log
                self.note = log.note ?? ""
                self.originalNote = log.note ?? ""
                self.progress = log.totalProgress
            } else {
                print("No daily log found for the date.")
            }
        }
    }
}

#Preview {
    EditExistingDayView(date: Date()) { _ in }
        .environmentObject(DailyLogRepository())
        .environmentObject(GoalRepository())
}
