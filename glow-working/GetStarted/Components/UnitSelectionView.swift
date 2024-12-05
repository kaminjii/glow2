//
//  UnitSelectionView.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import SwiftUI

// Unit selection view for the measurement section of new goal
struct UnitSelectionView: View {
    @Binding var selectedUnit: String // The unit selected by the user
    let units: [String: [String]] // Dictionary of unit categories and their respective units
    let dismiss: () -> Void // Callback function to dismiss the view
    
    var body: some View {
        ZStack {
            Color.whitePrimary.ignoresSafeArea()
            
            // Create a list to display unit categories and units
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
                                    // Display a checkmark if the current unit is the selected one
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
    UnitSelectionView(
        selectedUnit: .constant("kilometers"),
        units: [
            "Distance": ["kilometers", "meters", "miles", "yards"],
            "Time": ["hours", "minutes"],
            "Count": ["repetitions", "sets", "times"],
            "Weight": ["kilograms", "pounds"],
            "Other": ["pages", "meals", "tasks"]
        ],
        dismiss: { }
    )
}


