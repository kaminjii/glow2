import SwiftUI
import FirebaseFirestore

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
    
    let date: Date
    var onSave: (DailyLog) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                if dailyLog != nil {
                    ScrollView {
                        VStack(spacing: 24) {
                            progressCard
                            goalsList
                            noteSection
                            photoSection
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                } else {
                    ProgressView("Loading...")
                        .onAppear {
                            fetchDailyLog(for: date)
                            goalRepository.fetchGoals(for: date)
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
        .sheet(item: $selectedGoal) { goal in
            EditGoalProgressView(goal: .constant(goal)) {
                fetchDailyLog(for: date)
                goalRepository.fetchGoals(for: date)
            }
            .presentationDetents([.fraction(0.5), .large])
        }
        .fullScreenCover(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onReceive(goalRepository.$goals) { fetchedGoals in
            self.goals = fetchedGoals
        }
    }
    
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
    }
    
    private var goalsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(.headline)
                .foregroundStyle(.black1)
            
            GoalsList(goals: $goals, onGoalSelected: { selectedGoal in
                self.selectedGoal = selectedGoal
            }, showValue: true)
        }
    }
    
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
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(.headline)
                .foregroundStyle(.black1)
            
            ImagePicker(
                selectedImage: $selectedImage,
                isPickerPresented: $isPickerPresented
            )
            .frame(minHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .blackShadow, radius: 10, y: 5)
            )
            
            if selectedImage == nil {
                Text("Add a photo to track your progress")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
                    .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func updateGoal(_ updatedGoal: Goal) {
        goalRepository.updateGoal(updatedGoal)
    }

    private func saveChanges() {
        if var dailyLog = dailyLog {
            if note != originalNote {
                dailyLog.note = note
            }

            onSave(dailyLog)
            
            dailyLogRepository.updateDailyLog(dailyLog) { success in
                if success {
                    print("Daily log updated successfully")
                } else {
                    print("Failed to update daily log")
                }
            }
        }

        for goal in goalRepository.goals {
            updateGoal(goal)
        }

        fetchDailyLog(for: date)
        goalRepository.fetchGoals(for: date)

        presentationMode.wrappedValue.dismiss()
    }

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
