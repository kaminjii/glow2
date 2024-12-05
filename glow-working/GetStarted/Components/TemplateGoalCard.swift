//
//  TemplateGoalCard.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/5/24.
//

import SwiftUI

struct TemplateGoalCard: View {
    let goal: TemplateGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goal.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue1)
                
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray1)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue1 : Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
    }
}
