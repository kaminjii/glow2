//
//  ProfileScreenView.swift
//  glow-working
//
//  Created by Alfredo Ruiz on 10/24/24.
//

import SwiftUI
import FirebaseFirestore

struct Achievement: Hashable {
    var title: String
    var description: String
}

enum EditType {
    case name, email, password
}

struct ProfileScreenView: View {
    
    @State private var navigationPath = NavigationPath()
    @Binding var selectedTab: Int
    
    // Firebase queries will be added here, but for now, we'll use placeholder values
    // @FirebaseQuery var firstName: String
    // @FirebaseQuery var dailyLogs: [DailyLog]
    // @FirebaseQuery var achievements: [Achievement]
    
    // This could be a computed property summing the number of daily logs
    var recordedDays: Int {
        return 204 // Example static value for now, replace with actual computation
    }
    
    // This could be a computed property calculating the current streak
    var userStreak: Int {
        return 6 // Example static value for now, replace with actual computation
    }
    
    // Placeholder for achievement count
    var totalAchievements: Int {
        return 6 // Example static value for now, replace with actual Firebase data
    }
    
    var body: some View {
        
        NavigationStack(path: $navigationPath) {
            ZStack{
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .trailing, spacing: -45) {
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 28))
                        .opacity(0.5)
                        .padding(30)
                        .onTapGesture {
                            navigationPath.append("editProfile")
                        }
                    
                    VStack(spacing: 20){
                        // Top image for profile
                        Image(.star3)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 141, height: 141)
                            .shadow(color: .blackShadow, radius: 40, x: 15, y: 15)
                        
                        // Display user's first name from Firebase
                        Text("Kaitlin") // Replace with actual firstName from Firebase
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        // HStack for recorded days and streak
                        HStack {
                            
                            // Recorded Days section
                            HStack(spacing: 15) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                    //                                    .scaledToFit()
                                        .frame(width: 31, height: 31)
                                        .background(.white.opacity(0.1))
                                    
                                    Image(systemName: "pencil")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                }
                                //                            .background(Color.white.opacity(0.1))
                                
                                VStack(alignment: .leading) {
                                    Text("Recorded Days")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                    Text("\(recordedDays)")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                            
                            Divider()
                                .frame(height: 60)
                                .background(Color.white)
                            
                            Spacer()
                            
                            // Streak section
                            HStack(spacing: 15) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                    //                                    .scaledToFit()
                                        .frame(width: 31, height: 31)
                                        .background(.white.opacity(0.1))
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                }
                                //                            .background(Color.white.opacity(0.1))
                                
                                VStack(alignment: .leading) {
                                    Text("Streak")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .opacity(0.5)
                                    Text("\(userStreak) Days")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue1)
                        .cornerRadius(16)
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading) {
                            // Achievements title
                            Text("Achievements")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 24)
                        }
                        
                        
                        // For each loop for achievements
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(achievementsPlaceholder(), id: \.self) { achievement in
                                    HStack {
                                        GradientIcon(iconName: "trophy.fill")
                                            .foregroundColor(Color.black)
                                            .padding(.horizontal)
                                        VStack(alignment: .leading) {
                                            Text(achievement.title)
                                                .fontWeight(.bold)
                                            Text(achievement.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray1)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: .blackShadow.opacity(0.1), radius: 10, x: 0, y: 5)
                                }
                            }
                            
                            VStack (alignment: .trailing){
                                // Total Achievements
                                Text("Total Achievements: \(totalAchievements)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                        }
                        .onAppear {
                            UIScrollView.appearance().bounces = false
                        }
                        .onDisappear {
                            UIScrollView.appearance().bounces = true
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
            }
            .navigationDestination(for: String.self) { value in
                if value == "editProfile" {
                    EditProfileView(navigationPath: $navigationPath)
                }
            }
        }
    }
    
    // Placeholder function for achievements
    func achievementsPlaceholder() -> [Achievement] {
        return [
            Achievement(title: "Tic-tac-toe", description: "Complete 100% of goals 4 days in a row"),
            Achievement(title: "100% complete", description: "Complete 100% of goals on 1 day"),
            Achievement(title: "1 week streak", description: "Log progress with Glow for 7 days in a row"),
            Achievement(title: "6 month user", description: "Log progress with Glow for 6 months"),
            Achievement(title: "Consistency is key", description: "Log over 50% progress for 30 days in a row"),
            Achievement(title: "Getting started", description: "Log progress with Glow for 1 day")
        ]
    }
}

#Preview {
    ProfileScreenView(selectedTab: .constant((3)))
}

