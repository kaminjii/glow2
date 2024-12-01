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
        ZStack {
            Color.whitePrimary.edgesIgnoringSafeArea(.all)
            VStack {
                headerView
                if dailyLog != nil {
                    progressSection
                    contentScrollView
                    saveButton
                        .padding()
                } else {
                    ProgressView("Loading...")
                        .onAppear {
                            fetchDailyLog(for: date)
                            goalRepository.fetchGoals(for: date)
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

    // MARK: - Header View
    private var headerView: some View {
        ZStack {
            HStack {
                backButton
                Spacer()
            }
            if let dailyLog = dailyLog {
                Text(formattedDate(for: dailyLog.date.dateValue())).bold()
            }
        }
    }

    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back").fontWeight(.medium)
            }
            .padding()
        }
    }
    
    private var progressSection: some View {
        HStack {
            ProgressBar(progress: progress)
            Text("\(Int(progress * 100))%")
                .font(.body)
                .foregroundStyle(.gray1)
                .frame(width: 50)
        }
        .padding(.horizontal)
    }

    // MARK: - Content ScrollView
    private var contentScrollView: some View {
        ScrollView {
            VStack {
                GoalsList(goals: $goals, onGoalSelected: { selectedGoal in
                    self.selectedGoal = selectedGoal
                }, showValue: true)
                noteTextEditor
                    .padding()
                imagePicker
                    .padding()
                Spacer()
            }
            .padding(.vertical)
            .background(Color.whitePrimary.edgesIgnoringSafeArea(.all))
        }
    }

    // MARK: - Note Text Editor
    private var noteTextEditor: some View {
        NoteTextEditor(note: $note, originalNote: $originalNote)
    }

    // MARK: - Image Picker
    private var imagePicker: some View {
        ImagePicker(selectedImage: $selectedImage, isPickerPresented: $isPickerPresented)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        GradientButton(title: "Save", action: saveChanges, isEnabled: true)
    }

    // MARK: - Functions
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

        // Update each goal to ensure persistence of changes
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
                self.note = log.note!
                self.originalNote = log.note!
                self.progress = log.totalProgress
                
            } else {
                print("No daily log found for the date.")
            }
        }
    }
}

#Preview {
    EditExistingDayView(date: Date(), onSave: { _ in })
        .environmentObject(DailyLogRepository())
        .environmentObject(GoalRepository())
}
