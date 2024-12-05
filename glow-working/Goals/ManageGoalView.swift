import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SymbolPicker

// View for managing a goal (either creating a new one or editing an existing one)
struct ManageGoalView: View {
    let isEditing: Bool               // Flag indicating if we're editing an existing goal
    let existingGoal: Goal?           // Optional existing goal to be edited
    
    @Environment(\.dismiss) private var dismiss // Environment property for dismissing the view
    
    // State variables for goal properties
    @State private var icon: String
    @State private var name: String
    @State private var description: String
    @State private var unit: String
    @State private var quantity: String
    
    // Flags for showing picker views
    @State private var showIconPicker = false
    @State private var showUnitPicker = false
    
    private let db = Firestore.firestore() // Firebase Firestore instance for database operations
    
    // Initializer to set up the view with either new or existing goal data
    init(isEditing: Bool = false, goal: Goal? = nil) {
        self.isEditing = isEditing
        self.existingGoal = goal
        
        // Initialize state with existing goal data or set defaults
        _icon = State(initialValue: goal?.icon ?? "star.fill")
        _name = State(initialValue: goal?.name ?? "")
        _description = State(initialValue: goal?.detail ?? "")
        _unit = State(initialValue: goal?.unit ?? "")
        _quantity = State(initialValue: goal?.quantityGoal.description ?? "")
    }
    
    // Predefined units for categorizing goals
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
                // Background color of the view
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                // Scroll view to allow for scrolling content when keyboard is present
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Icon picker button
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
                        
                        // Goal details section
                        VStack(alignment: .leading, spacing: 16) {
                            inputField(title: "Name", icon: "pencil", placeholder: "Enter goal name", text: $name)
                            inputField(title: "Description", icon: "text.justify", placeholder: "Enter goal description (optional)", text: $description)
                        }
                        
                        // Unit picker section
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
                        
                        // Quantity input (if a unit is selected)
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
                // Toolbar title and buttons
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
                    .disabled(!isValid) // Disable the button if the form is invalid
                }
            }
            // Sheet for icon picker
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
            // Sheet for unit picker
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
    
    // Computed property to check if the form is valid
    private var isValid: Bool {
        !name.isEmpty && !unit.isEmpty && !quantity.isEmpty
    }
    
    // Helper function to create a text input field
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
    
    // Function to save a new goal to Firestore
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
    
    // Function to update an existing goal in Firestore
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

// Sub-view for selecting a unit from predefined categories
struct UnitPickerView: View {
    @Binding var selectedUnit: String // Binding to capture the selected unit
    let units: [String: [String]]     // Dictionary of unit categories and their units
    let dismiss: () -> Void           // Closure to dismiss the picker view
    
    var body: some View {
        List {
            // Iterate over each category and its units
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
            // Toolbar item for confirmation action
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
