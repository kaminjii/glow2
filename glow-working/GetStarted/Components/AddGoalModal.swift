import SwiftUI
import SymbolPicker
import FirebaseAuth

struct AddGoalModal: View {
    let units = [
        "Distance": ["kilometers", "meters", "miles", "yards"],
        "Time": ["hours", "minutes"],
        "Count": ["repetitions", "sets", "times"],
        "Weight": ["kilograms", "pounds"],
        "Other": ["pages", "meals", "tasks"]
    ]
    
    @Environment(\.dismiss) private var dismiss
    @State private var icon: String = "star.fill"
    @State private var iconPickerPresented = false
    @State private var goalName: String = ""
    @State private var goalDescription: String = ""
    @State private var goalUnit: String = ""
    @State private var quantity: String = ""
    @State private var showUnitSheet = false
    @State private var selectedCategory: String?
    
    let onAddGoal: (TemplateGoal) -> Void

    var formIsValid: Bool {
        !goalName.isEmpty && !goalUnit.isEmpty && !quantity.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        iconSection
                        goalDetailsSection
                        measurementSection
                        
                        if !goalUnit.isEmpty {
                            targetSection
                                .transition(.opacity)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveGoal()
                    }
                    .bold()
                    .disabled(!formIsValid)
                }
                ToolbarItem(placement: .principal) {
                    Text("New Goal")
                        .font(.headline)
                }
            }
            .sheet(isPresented: $iconPickerPresented) {
                NavigationStack {
                    SymbolPicker(symbol: $icon)
                        .navigationTitle("Choose Icon")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    iconPickerPresented = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var iconSection: some View {
        VStack(spacing: 16) {
            Button(action: { iconPickerPresented = true }) {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 40))
                            .foregroundStyle(.black1)
                    )
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .blue1)
                            .font(.system(size: 24))
                            .background(Circle().fill(.white))
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var goalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .foregroundStyle(.gray1)
                    .font(.subheadline)
                AppTextField(
                    icon: "pencil",
                    placeholder: "Enter goal name",
                    label: $goalName
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .foregroundStyle(.gray1)
                    .font(.subheadline)
                AppTextField(
                    icon: "text.justify",
                    placeholder: "Enter goal description (optional)",
                    label: $goalDescription
                )
            }
        }
    }

    private var measurementSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unit")
                .foregroundStyle(.gray1)
                .font(.subheadline)
            
            Button(action: { showUnitSheet.toggle() }) {
                HStack {
                    Image(systemName: "ruler")
                        .foregroundStyle(.gray1)
                    Text(goalUnit.isEmpty ? "Choose measurement unit" : goalUnit)
                        .foregroundStyle(goalUnit.isEmpty ? .gray1 : .black1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray1)
                        .font(.system(size: 14))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.gray2))
            }
            .sheet(isPresented: $showUnitSheet) {
                NavigationStack {
                    UnitSelectionView(
                        selectedUnit: $goalUnit,
                        units: units,
                        dismiss: { showUnitSheet = false }
                    )
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Target")
                .foregroundStyle(.gray1)
                .font(.subheadline)
            
            AppTextField(
                icon: "target",
                placeholder: "Enter amount",
                label: $quantity
            )
            .keyboardType(.decimalPad)
            
            Text("Set your target goal in \(goalUnit)")
                .font(.footnote)
                .foregroundStyle(.gray1)
                .padding(.leading, 4)
        }
    }
    
    private func saveGoal() {
        let newGoal = TemplateGoal(
            iconName: icon,
            title: goalName,
            description: goalDescription,
            checked: true
        )
        onAddGoal(newGoal)
        dismiss()
    }
}

struct UnitSelectionView: View {
    @Binding var selectedUnit: String
    let units: [String: [String]]
    let dismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.whitePrimary.ignoresSafeArea()
            
            List {
                ForEach(Array(units.keys).sorted(), id: \.self) { category in
                    Section(category) {
                        ForEach(units[category] ?? [], id: \.self) { unit in
                            Button(action: {
                                selectedUnit = unit
                                dismiss()
                            }) {
                                HStack {
                                    Text(unit)
                                    Spacer()
                                    if selectedUnit == unit {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue1)
                                    }
                                }
                            }
                            .foregroundStyle(.black1)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Choose Unit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview {
    AddGoalModal { _ in }
}
