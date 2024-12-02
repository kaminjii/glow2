import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SymbolPicker

struct ManageGoalView: View {
    let isEditing: Bool
    let existingGoal: Goal?
    @Environment(\.dismiss) private var dismiss
    @State private var icon: String
    @State private var name: String
    @State private var description: String
    @State private var unit: String
    @State private var quantity: String
    @State private var showIconPicker = false
    @State private var showUnitPicker = false
    
    private let db = Firestore.firestore()
    
    init(isEditing: Bool = false, goal: Goal? = nil) {
        self.isEditing = isEditing
        self.existingGoal = goal
        
        // Initialize state with existing goal data or defaults
        _icon = State(initialValue: goal?.icon ?? "star.fill")
        _name = State(initialValue: goal?.name ?? "")
        _description = State(initialValue: goal?.detail ?? "")
        _unit = State(initialValue: goal?.unit ?? "")
        _quantity = State(initialValue: goal?.quantityGoal.description ?? "")
    }
    
    let units = [
        "Distance": ["kilometers", "meters", "miles", "yards"],
        "Time": ["hours", "minutes"],
        "Count": ["repetitions", "sets", "times"],
        "Weight": ["kilograms", "pounds"],
        "Other": ["pages", "meals", "tasks"]
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Icon selector
                        Button(action: { showIconPicker = true }) {
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
                        
                        // Goal details
                        VStack(alignment: .leading, spacing: 16) {
                            inputField(title: "Name", icon: "pencil", placeholder: "Enter goal name", text: $name)
                            inputField(title: "Description", icon: "text.justify", placeholder: "Enter goal description (optional)", text: $description)
                        }
                        
                        // Unit selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unit")
                                .foregroundStyle(.gray1)
                                .font(.subheadline)
                            
                            Button(action: { showUnitPicker = true }) {
                                HStack {
                                    Image(systemName: "ruler")
                                        .foregroundStyle(.gray1)
                                    Text(unit.isEmpty ? "Choose measurement unit" : unit)
                                        .foregroundStyle(unit.isEmpty ? .gray1 : .black1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.gray1)
                                }
                                .padding()
                                .background(Color.gray2)
                                .cornerRadius(14)
                            }
                        }
                        
                        // Quantity input (if unit selected)
                        if !unit.isEmpty {
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
                                
                                Text("Set your target goal in \(unit)")
                                    .font(.footnote)
                                    .foregroundStyle(.gray1)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isEditing ? "Edit Goal" : "New Goal")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Add") {
                        if isEditing {
                            updateGoal()
                        } else {
                            saveNewGoal()
                        }
                        dismiss()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                NavigationStack {
                    SymbolPicker(symbol: $icon)
                        .navigationTitle("Choose Icon")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showIconPicker = false }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showUnitPicker) {
                NavigationStack {
                    UnitPickerView(selectedUnit: $unit, units: units) {
                        showUnitPicker = false
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !unit.isEmpty && !quantity.isEmpty
    }
    
    private func inputField(title: String, icon: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(.gray1)
                .font(.subheadline)
            AppTextField(
                icon: icon,
                placeholder: placeholder,
                label: text
            )
        }
    }
    
    private func saveNewGoal() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let goal = Goal(
            date: Timestamp(date: Date()),
            deleted: false,
            detail: description,
            icon: icon,
            name: name,
            quantityComplete: 0,
            quantityGoal: Double(quantity) ?? 0,
            unit: unit
        )
        
        do {
            _ = try db.collection("users").document(userId).collection("goals")
                .addDocument(from: goal)
        } catch {
            print("Error saving goal: \(error)")
        }
    }
    
    private func updateGoal() {
        guard let userId = Auth.auth().currentUser?.uid,
              let goalId = existingGoal?.id else { return }
        
        let updates: [String: Any] = [
            "icon": icon,
            "name": name,
            "detail": description,
            "unit": unit,
            "quantityGoal": Double(quantity) ?? 0
        ]
        
        db.collection("users").document(userId).collection("goals")
            .document(goalId)
            .updateData(updates)
    }
}

struct UnitPickerView: View {
    @Binding var selectedUnit: String
    let units: [String: [String]]
    let dismiss: () -> Void
    
    var body: some View {
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
        .navigationTitle("Choose Unit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
