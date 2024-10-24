import SwiftUI
import SymbolPicker
import Firebase

struct EditGoalModal: View {
    let units = ["kg", "g", "lb", "oz"]
    
    @Environment(\.presentationMode) var presentationMode
        
    @State private var icon: String = "star.fill"
    @State private var iconPickerPresented = false

    @State var goalName: String = ""
    @State var goalDescription: String = ""
    @State var goalUnit: String = ""
    @State private var quantity: String = ""
    
    @State private var isButtonEnabled: Bool = false
    
    @State private var isPresented: Bool = false

    var goal: Goal?

    var body: some View {
        VStack(spacing: 20) {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.gray1)
            }
            
            Text("Edit Goal")
                .font(.title)
            
            HStack(spacing: 12) {
                ZStack {
                    GradientIcon(iconName: icon)
                    
                    Button(action: { iconPickerPresented = true }) {
                        HStack {
                            Image(systemName:"pencil")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .foregroundColor(.white)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(30)
                    }
                    .sheet(isPresented: $iconPickerPresented) {
                        SymbolPicker(symbol: $icon)
                    }
                }
                
                AppTextField(icon: "trophy.fill", placeholder: "Goal name", label: $goalName)
            }
                
            AppTextField(icon: "pencil", placeholder: "Goal description", label: $goalDescription)
             
            HStack {
                VStack(spacing: 3) {
                    Text("Unit")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundStyle(.gray1)
                    
                    Picker("Select a Unit", selection: $goalUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.gray2))
                    .onChange(of: goalUnit) { oldValue, newValue in
                        if !newValue.isEmpty {
                            quantity = ""
                            isButtonEnabled = true
                        } else {
                            isButtonEnabled = false
                        }
                    }
                }
                
                if isButtonEnabled {
                    VStack(spacing: 3) {
                        Text("Quantity")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundStyle(.gray1)
                        TextField("0", text: $quantity)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.gray2))
                    }
                }
            }
            
            GradientButton(title: "Save", action: { presentationMode.wrappedValue.dismiss() }, isEnabled: isButtonEnabled)
                .padding(.vertical)
        }
        .onAppear {
            if let goal = goal {
                self.icon = goal.icon
                self.goalName = goal.name
                self.goalDescription = goal.detail ?? ""
                self.goalUnit = goal.unit
                self.quantity = "\(goal.quantityGoal)"
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.whitePrimary)
        .cornerRadius(12)
        .shadow(radius: 20)
        .padding()
        .frame(maxHeight: .infinity, alignment: .center)
    }
//
//    private func saveGoal() {
//        guard let goal = goal, let goalId = goal.id else { return }
//
//        // Update goal in Firestore
//        Firestore.firestore().collection("goals").document(goalId).updateData([
//            "name": goalName,
//            "detail": goalDescription,
//            "unit": goalUnit,
//            "quantityGoal": Double(quantity) ?? 0.0,
//            "icon": icon
//        ]) { error in
//            if let error = error {
//                print("Error updating goal: \(error)")
//            } else {
//                print("Goal updated successfully.")
//            }
//        }
//        
//        presentationMode.wrappedValue.dismiss()
//    }
}


#Preview {
    EditGoalModal()
}
