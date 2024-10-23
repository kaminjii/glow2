import SwiftUI
import FirebaseCore

struct EditGoalProgressView: View {
    @ObservedObject var viewModel: EditGoalProgressViewModel
    
    @Environment(\.dismiss) var dismiss
    var onSave: () -> Void
    
    init(goal: Binding<Goal>, onSave: @escaping () -> Void) {
        self.viewModel = EditGoalProgressViewModel(goal: goal.wrappedValue)
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .edgesIgnoringSafeArea(.bottom)
        .gesture(dragGesture)
        .onAppear(perform: viewModel.fetchGoalData)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 0, style: .continuous)
            .fill(Color.sheet1)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            goalInfo
            goalInputSection
            saveButton
        }
        .padding()
        .frame(height: 375)
    }
    
    private var goalInfo: some View {
        HStack {
            LargeGradientIcon(iconName: viewModel.goal.icon)
                .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(viewModel.goal.name)
                    .font(.title)
                    .foregroundStyle(.black1)
                Text(viewModel.goal.detail ?? "")
                    .font(.title3)
                    .foregroundStyle(.gray1)
            }
            Spacer()
        }
        .padding(.bottom, 30)
    }
    
    private var goalInputSection: some View {
        VStack(spacing: 0) {
            Text(viewModel.goal.unit)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                goalSlider
                inputTextField
            }
            .padding(.bottom, 40)
        }
    }
    
    private var goalSlider: some View {
        Slider(value: Binding(
            get: { viewModel.goal.quantityComplete },
            set: { newValue in
                viewModel.goal.quantityComplete = newValue
                viewModel.inputValue = String(format: "%.2f", newValue)
            }
        ), in: 0...Double(viewModel.goal.quantityGoal))
    }
    
    private var inputTextField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray1, lineWidth: 1)
            
            TextField("0", text: $viewModel.inputValue)
                .padding(10)
                .foregroundStyle(.black1)
                .keyboardType(.decimalPad)
                .onChange(of: viewModel.inputValue) { oldValue, newValue in
                    if let value = Double(newValue), value >= 0, value <= Double(viewModel.goal.quantityGoal) {
                        viewModel.goal.quantityComplete = value
                    } else {
                        print("Invalid input: \(newValue). Must be between 0 and \(viewModel.goal.quantityGoal).")
                    }
                }
        }
        .frame(width: 70, height: 20, alignment: .trailing)
    }
    
    private var saveButton: some View {
        GradientButton(title: "Save", action: {
            viewModel.saveGoal {
                onSave() 
                dismiss()
            }
        }, isEnabled: true)
    }
    
    private var dragGesture: some Gesture {
        DragGesture().onEnded { value in
            if value.translation.height > 100 {
                dismiss()
            }
        }
    }
}


#Preview {
    let sampleGoal = Goal(id: "\(UUID())", date: Timestamp(date: Date()), deleted: false, detail: "Exercise for 1 hour", icon: "figure.run", name: "Exercise", quantityComplete: 0.5, quantityGoal: 1, unit: "hours")
    
    EditGoalProgressView(goal: .constant(sampleGoal), onSave: {})
}
