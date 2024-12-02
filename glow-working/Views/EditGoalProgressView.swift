import SwiftUI
import FirebaseCore

struct EditGoalProgressView: View {
    @Binding var goal: Goal
    @ObservedObject var viewModel: EditGoalProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var onSave: () -> Void
    
    init(goal: Binding<Goal>, onSave: @escaping () -> Void) {
        self._goal = goal
        self.viewModel = EditGoalProgressViewModel(goal: goal.wrappedValue)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    goalInfo
                    progressSection
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        handleSave()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.goal.name)
                        .font(.headline)
                }
            }
        }
        .onAppear(perform: viewModel.fetchGoalData)
        .presentationDragIndicator(.visible)
    }
    
    private var goalInfo: some View {
        HStack(spacing: 20) {
            LargeGradientIcon(iconName: viewModel.goal.icon)
                .frame(width: 70, height: 70)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.goal.name)
                    .font(.title2.bold())
                    .foregroundStyle(.black1)
                Text(viewModel.goal.detail ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
                    .lineLimit(2)
            }
            Spacer()
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress")
                    .font(.headline)
                    .foregroundStyle(.black1)
                Text("\(viewModel.goal.quantityComplete, specifier: "%.1f") of \(viewModel.goal.quantityGoal, specifier: "%.1f") \(viewModel.goal.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
            }
            
            progressControls
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
    
    private var progressControls: some View {
        VStack(spacing: 16) {
            // Slider
            Slider(value: Binding(
                get: { viewModel.goal.quantityComplete },
                set: { newValue in
                    viewModel.goal.quantityComplete = newValue
                    viewModel.inputValue = String(format: "%.1f", newValue)
                }
            ), in: 0...Double(viewModel.goal.quantityGoal))
            .tint(.blue1)
            
            // Manual Input
            HStack {
                Text("Enter value:")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
                
                TextField("0", text: $viewModel.inputValue)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray2)
                    )
                    .onChange(of: viewModel.inputValue) { _, newValue in
                        if let value = Double(newValue), value >= 0, value <= Double(viewModel.goal.quantityGoal) {
                            viewModel.goal.quantityComplete = value
                        }
                    }
                
                Text(viewModel.goal.unit)
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
            }
        }
    }
    
    private func handleSave() {
        viewModel.saveGoal {
            let dailyLogRepository = DailyLogRepository()
            let goalDate = viewModel.goal.date.dateValue()
            
            dailyLogRepository.updateTotalProgress(for: goalDate) {
                DispatchQueue.main.async {
                    self.goal = viewModel.goal
                    dismiss()
                    onSave()
                }
            }
        }
    }
}

#Preview {
    let sampleGoal = Goal(
        id: "\(UUID())",
        date: Timestamp(date: Date()),
        deleted: false,
        detail: "Exercise for 1 hour",
        icon: "figure.run",
        name: "Exercise",
        quantityComplete: 0.5,
        quantityGoal: 1,
        unit: "hours"
    )
    
    return EditGoalProgressView(goal: .constant(sampleGoal), onSave: {})
}
