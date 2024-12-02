//
//  SocialFeatures.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/2/24.
//

import SwiftUI
import FirebaseFirestore

struct SocialFeaturesShowcase: View {
    var body: some View {
        TabView {
            // Main Social View
            socialTab
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
            
            // Friends List
            friendsTab
                .tabItem {
                    Label("Friends", systemImage: "person.3.fill")
                }
            
            // Challenges
            challengesTab
                .tabItem {
                    Label("Challenges", systemImage: "trophy.fill")
                }
        }
    }
    
    // MARK: - Sample Data
    let sampleFriends: [Friend] = [
        Friend(
            userId: "1",
            username: "Sarah Wilson",
            profileImage: nil,
            goalCategories: ["Exercise", "Reading"],
            lastActive: Timestamp(date: Date()),
            streak: 7,
            totalProgress: 0.85
        ),
        Friend(
            userId: "2",
            username: "Mike Johnson",
            profileImage: nil,
            goalCategories: ["Meditation", "Study"],
            lastActive: Timestamp(date: Date()),
            streak: 12,
            totalProgress: 0.65
        ),
        Friend(
            userId: "3",
            username: "Emma Davis",
            profileImage: nil,
            goalCategories: ["Exercise", "Diet"],
            lastActive: Timestamp(date: Date()),
            streak: 21,
            totalProgress: 0.95
        )
    ]
    
    let sampleChallenges: [Challenge] = [
        Challenge(
            title: "30 Days of Exercise",
            description: "Exercise for at least 30 minutes every day",
            startDate: Timestamp(date: Date()),
            endDate: Timestamp(date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!),
            category: "Exercise",
            creatorId: "1",
            participants: ["1", "2", "3"],
            progress: ["1": 0.8, "2": 0.6, "3": 0.9],
            targetValue: 30,
            unit: "minutes"
        ),
        Challenge(
            title: "Reading Challenge",
            description: "Read for 20 minutes daily",
            startDate: Timestamp(date: Date()),
            endDate: Timestamp(date: Calendar.current.date(byAdding: .day, value: 14, to: Date())!),
            category: "Reading",
            creatorId: "2",
            participants: ["1", "2"],
            progress: ["1": 0.7, "2": 0.8],
            targetValue: 20,
            unit: "minutes"
        )
    ]
    
    // MARK: - Tabs
    private var socialTab: some View {
        NavigationStack {
            SocialView()
                .environmentObject(mockSocialViewModel)
        }
    }
    
    private var friendsTab: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(sampleFriends) { friend in
                        FriendCard(friend: friend)
                    }
                }
                .padding()
            }
            .navigationTitle("Friends")
        }
    }
    
    private var challengesTab: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(sampleChallenges) { challenge in
                        ChallengeCard(challenge: challenge)
                    }
                }
                .padding()
            }
            .navigationTitle("Challenges")
        }
    }
    
    // MARK: - Mock ViewModel
    private var mockSocialViewModel: SocialViewModel {
        let viewModel = SocialViewModel()
        viewModel.friends = sampleFriends
        viewModel.challenges = sampleChallenges
        return viewModel
    }
}

// MARK: - Preview Supporting Views
struct PreviewHeaderView: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title.bold())
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - Progress Demo
struct ProgressDemo: View {
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            CircularProgressView(progress: progress)
                .frame(width: 100, height: 100)
            
            Slider(value: $progress)
                .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Preview Provider
struct SocialFeaturesShowcase_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Full showcase
            SocialFeaturesShowcase()
                .preferredColorScheme(.light)
            
            // Individual components
            VStack(spacing: 20) {
                ProgressDemo()
                FriendCard(friend: SocialFeaturesShowcase().sampleFriends[0])
                ChallengeCard(challenge: SocialFeaturesShowcase().sampleChallenges[0])
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
}
