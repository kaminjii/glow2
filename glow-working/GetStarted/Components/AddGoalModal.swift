import SwiftUI
import SymbolPicker

struct AddGoalModal: View {
    let units = [
        "Distance": ["kilometers", "meters", "centimeters", "miles", "yards", "feet", "inches"],
        "Time": ["hours", "minutes", "seconds"]
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @State private var icon: String = "star.fill"
    @State private var iconPickerPresented = false
    @State var goalName: String = ""
    @State var goalDescription: String = ""
    @State var goalUnit: String = ""
    @State private var quantity: String = ""
    @State private var isButtonEnabled: Bool = false
    
    // New property to handle goal addition
    var onAddGoal: (TemplateGoal) -> Void

    var body: some View {
        ZStack {
            Color.whitePrimary.edgesIgnoringSafeArea(.all)
            
            NavigationStack {
                VStack(spacing: 16) {
                    iconSection
                    goalDetailsSection
                    unitAndQuantitySection
                    Spacer()
                }
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            let newGoal = TemplateGoal(iconName: icon, title: goalName, description: goalDescription, checked: true)
                            onAddGoal(newGoal) // Call the closure with the new goal
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }

    private var iconSection: some View {
        VStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellowGradientStart, Color.yellowGradientEnd]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .padding(30)
                    .foregroundColor(.black1)
            }
            .frame(width: 175, height: 175)
            .cornerRadius(100)
            .padding(.bottom, 3)
            
            Button(action: { iconPickerPresented = true }) {
                Text("Edit Icon")
                    .padding(5)
                    .frame(width: 125)
                    .background(Capsule().fill(Color.gray2))
                    .foregroundStyle(.gray1)
            }
            .sheet(isPresented: $iconPickerPresented) {
                SymbolPicker(symbol: $icon)
            }
        }
        .padding(.bottom)
    }

    private var goalDetailsSection: some View {
        VStack(spacing: 16) {
            AppTextField(icon: "trophy.fill", placeholder: "Goal name", label: $goalName)
            AppTextField(icon: "pencil", placeholder: "Goal description", label: $goalDescription)
        }
    }

    private var unitAndQuantitySection: some View {
        HStack {
            NavigationLink(destination: UnitSelectionView(selectedUnit: $goalUnit, units: units)) {
                unitPicker
            }
            if isButtonEnabled {
                quantityField
            }
        }
        .onChange(of: goalUnit) { oldValue, newValue in
            isButtonEnabled = !newValue.isEmpty
            if !isButtonEnabled { quantity = "" }
        }
    }

    private var unitPicker: some View {
        HStack {
            Text("Unit")
                .foregroundStyle(.gray1)
            Text(goalUnit.isEmpty ? "" : goalUnit)
                .foregroundStyle(.black1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray1)
        }
        .padding()
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.gray2))
    }
    
    private var quantityField: some View {
        TextField("Quantity", text: $quantity)
            .padding()
            .frame(width: 100, height: 50, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.gray2))
    }
}

struct UnitSelectionView: View {
    @Binding var selectedUnit: String
    let units: [String: [String]]
    
    var body: some View {
        List {
            ForEach(units.keys.sorted(), id: \.self) { section in
                Section(header: Text(section)) {
                    ForEach(units[section] ?? [], id: \.self) { unit in
                        Button(action: {
                            selectedUnit = unit
                        }) {
                            HStack {
                                Text(unit)
                                    .foregroundStyle(.black1)
                                if selectedUnit == unit {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Unit")
    }
}

struct MyModalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalModal(goalName: "", goalDescription: "", onAddGoal: { _ in })
    }
}
