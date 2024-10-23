//
//  StatsScreenView.swift
//  glow-working
//
//  Created by Alfredo Ruiz on 10/23/24.
//

import SwiftUI

struct StatsScreenView: View {

    let topGoals = [
        ("Exercise", "exercise_icon", 80),
        ("Drink water", "water_icon", 75),
        ("Meditate", "meditate_icon", 60)
    ]
    
    let bottomGoals = [
        ("Read", "read_icon", 10)
    ]
    
    let progressValues: [Double] = [0.0, 0.17, 0.50, 0.33, 0.0]
    
//    @State private var goals: [Goal] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {

            Text("Statistics")
                .font(.custom("Quicksand-Regular", size: 36))
                .fontWeight(.semibold)
                .padding(.top, 40)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Weekly Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 30) {
                    ForEach(progressValues.indices, id: \.self) { index in
                        let progress = progressValues[index]
                        VStack {
                            Image(starImage(for: index))
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.bottom, 5)
                            Text("\(Int(progress * 100))%")
                                .font(.caption).opacity(0.4)
                                .padding(.horizontal, 5)
                                .background(Capsule().fill(Color.gray.opacity(0.2)))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue1)
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.middleBrown)
                        .frame(width: 250, height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.yellow1)
                        .frame(width: 100, height: 20)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
            
            // Best & Worst Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Best & Worst")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Your top habits are...")
                    .font(.subheadline)
                
                HStack(spacing: 8) {
                    ForEach(topGoals, id: \.0) { goal in
                        HabitCardView(number: topGoals.firstIndex(where: { $0.0 == goal.0 })! + 1, name: goal.0, icon: goal.1, percentage: goal.2)
                    }
                }
                
                Text("Your bottom habits are...")
                    .font(.subheadline)
                
                HStack(spacing: 8) {
                    ForEach(bottomGoals, id: \.0) { goal in
                        HabitCardView(number: bottomGoals.firstIndex(where: { $0.0 == goal.0 })! + 1, name: goal.0, icon: goal.1, percentage: goal.2)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .shadow(radius: 1)
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
    }
    
        private func starImage(for index: Int) -> String {
            switch index {
            case 0:
                return "star1"
            case 1:
                return "star2"
            case 2:
                return "star3"
            case 3:
                return "star4"
            case 4:
                return "star5"
            default:
                return "star3"
            }
        }
        
        private func progressColor(for progress: Double) -> Color {
            switch progress {
            case 0..<0.2:
                return Color.yellow
            case 0.2..<0.4:
                return Color.gray
            case 0.4..<0.6:
                return Color.blue
            case 0.6..<0.8:
                return Color.green
            case 0.8...1.0:
                return Color.purple
            default:
                return Color.gray.opacity(0.2)
            }
        }
}

struct HabitCardView: View {
    let number: Int
    let name: String
    let icon: String
    let percentage: Int
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 8) {
                
                GradientIcon(iconName: "figure.run")
                    .frame(width: 35, height: 35)
                
                Text(name)
                    .font(.system(size: 12)).opacity(0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text("\(percentage)%")
                    .font(.caption)
                    .foregroundColor(.gray2)
                    .padding(.horizontal, 5)
                    .background(Capsule().fill(.blue1))
            }
            .padding(.top, 10)
            .frame(width: 92, height: 107)
            .background(.grayHabitStats)
            .cornerRadius(12)
            .shadow(radius: 2)
            
            Text("\(number)")
                .font(.caption)
                .padding(5)
        }
    }
}

#Preview {
    StatsScreenView()
}

