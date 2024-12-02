//
//  SocialPages.swift
//  glow-working
//
//  Created by Kaitlin Wood on 12/2/24.
//

// Models/SocialModels.swift
import FirebaseFirestore
import SwiftUI
import FirebaseAuth

struct Friend: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var username: String
    var profileImage: String?
    var goalCategories: [String]
    var lastActive: Timestamp
    var streak: Int
    var totalProgress: Double
}

struct Challenge: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var startDate: Timestamp
    var endDate: Timestamp
    var category: String
    var creatorId: String
    var participants: [String]
    var progress: [String: Double]
    var targetValue: Double
    var unit: String
}

// Views/SocialView.swift
struct SocialView: View {
    @StateObject private var viewModel = SocialViewModel()
    @State private var selectedTab = 0
    @State private var showAddFriend = false
    @State private var showCreateChallenge = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom segmented control
                HStack(spacing: 0) {
                    tabButton("Friends", index: 0)
                    tabButton("Challenges", index: 1)
                }
                .padding(.horizontal)
                .padding(.top)
                
                TabView(selection: $selectedTab) {
                    FriendsListView(friends: viewModel.friends)
                        .tag(0)
                    
                    ChallengesView(challenges: viewModel.challenges)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Social")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            showAddFriend = true
                        } else {
                            showCreateChallenge = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFriend) {
                AddFriendView(viewModel: viewModel)
            }
            .sheet(isPresented: $showCreateChallenge) {
                CreateChallengeView(viewModel: viewModel)
            }
        }
    }
    
    private func tabButton(_ title: String, index: Int) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = index
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(selectedTab == index ? .black1 : .gray1)
                
                Rectangle()
                    .fill(selectedTab == index ? Color.blue1 : .clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Friend List View
struct FriendsListView: View {
    let friends: [Friend]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(friends) { friend in
                    FriendCard(friend: friend)
                }
            }
            .padding()
        }
    }
}

struct FriendCard: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: friend.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray2)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.username)
                    .font(.headline)
                
                Text("\(friend.streak) day streak")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
            }
            
            Spacer()
            
            // Progress
            CircularProgressView(progress: friend.totalProgress)
                .frame(width: 40, height: 40)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
}

// Challenge Views
struct ChallengesView: View {
    let challenges: [Challenge]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !activeChallenge.isEmpty {
                    Section("Active Challenges") {
                        ForEach(activeChallenge) { challenge in
                            ChallengeCard(challenge: challenge)
                        }
                    }
                }
                
                if !upcomingChallenges.isEmpty {
                    Section("Upcoming") {
                        ForEach(upcomingChallenges) { challenge in
                            ChallengeCard(challenge: challenge)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var activeChallenge: [Challenge] {
        challenges.filter { challenge in
            let now = Date()
            return challenge.startDate.dateValue() <= now && challenge.endDate.dateValue() >= now
        }
    }
    
    private var upcomingChallenges: [Challenge] {
        challenges.filter { $0.startDate.dateValue() > Date() }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    @StateObject private var viewModel = ChallengeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundStyle(.gray1)
                }
                
                Spacer()
                
                Menu {
                    Button("Share", action: viewModel.shareChallenge)
                    Button("Leave", action: viewModel.leaveChallenge)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.gray1)
                }
            }
            
            // Progress
            VStack(spacing: 8) {
                ProgressBar(progress: viewModel.averageProgress)
                
                HStack {
                    Text("Group Progress")
                        .font(.subheadline)
                        .foregroundStyle(.gray1)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.averageProgress * 100))%")
                        .font(.headline)
                }
            }
            
            // Participants
            HStack {
                ForEach(viewModel.participants.prefix(3)) { participant in
                    AsyncImage(url: URL(string: participant.profileImage ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.gray2)
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                }
                
                if viewModel.participants.count > 3 {
                    Text("+\(viewModel.participants.count - 3)")
                        .font(.caption)
                        .foregroundStyle(.gray1)
                }
                
                Spacer()
                
                // Time remaining
                Text(viewModel.timeRemaining)
                    .font(.caption)
                    .foregroundStyle(.gray1)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
        .onAppear {
            viewModel.setup(with: challenge)
        }
    }
}

// ViewModels/SocialViewModel.swift
class SocialViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var challenges: [Challenge] = []
    private let db = Firestore.firestore()
    
    init() {
        fetchFriends()
        fetchChallenges()
    }
    
    func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("friends")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.friends = documents.compactMap { try? $0.data(as: Friend.self) }
            }
    }
    
    func fetchChallenges() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("challenges")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.challenges = documents.compactMap { try? $0.data(as: Challenge.self) }
            }
    }
    
    func addFriend(userId: String) async throws {
        // Implementation for adding friends
    }
    
    func createChallenge(_ challenge: Challenge) async throws {
        // Implementation for creating challenges
    }
}

// CircularProgressView.swift
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray2, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue1, .bottomBlue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

// AddFriendView.swift
struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SocialViewModel
    @State private var searchText = ""
    @State private var searchResults: [Friend] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Search bar
                    AppTextField(
                        icon: "magnifyingglass",
                        placeholder: "Search by username or email",
                        label: $searchText
                    )
                    .padding(.horizontal)
                    .onChange(of: searchText) { _, newValue in
                        if !newValue.isEmpty {
                            searchUsers(query: newValue)
                        }
                    }
                    
                    if isSearching {
                        ProgressView()
                    } else if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding()
                    } else if searchResults.isEmpty && !searchText.isEmpty {
                        Text("No users found")
                            .font(.headline)
                            .foregroundStyle(.gray1)
                            .padding()
                    } else {
                        // Search results
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(searchResults) { user in
                                    SearchResultRow(user: user) {
                                        Task {
                                            try? await viewModel.addFriend(userId: user.userId)
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchUsers(query: String) {
        // Implementation for searching users
    }
}

// CreateChallengeView.swift
struct CreateChallengeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SocialViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var category = "Exercise"
    @State private var targetValue = ""
    @State private var unit = "minutes"
    @State private var startDate = Date()
    @State private var duration = 7 // days
    @State private var selectedFriends: Set<String> = []
    
    let categories = ["Exercise", "Reading", "Meditation", "Study", "Custom"]
    let units = ["minutes", "hours", "times", "repetitions"]
    let durations = [7, 14, 30, 60]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Challenge Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section("Goal") {
                    HStack {
                        TextField("Target", text: $targetValue)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $unit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Duration") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Picker("Duration", selection: $duration) {
                        ForEach(durations, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                }
                
                Section("Invite Friends") {
                    ForEach(viewModel.friends) { friend in
                        HStack {
                            FriendRow(friend: friend)
                            Spacer()
                            if selectedFriends.contains(friend.userId) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue1)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFriends.contains(friend.userId) {
                                selectedFriends.remove(friend.userId)
                            } else {
                                selectedFriends.insert(friend.userId)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createChallenge()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && !description.isEmpty && !targetValue.isEmpty && !selectedFriends.isEmpty
    }
    
    private func createChallenge() {
        guard let targetDouble = Double(targetValue) else { return }
        
        let challenge = Challenge(
            title: title,
            description: description,
            startDate: Timestamp(date: startDate),
            endDate: Timestamp(date: Calendar.current.date(byAdding: .day, value: duration, to: startDate)!),
            category: category,
            creatorId: Auth.auth().currentUser?.uid ?? "",
            participants: Array(selectedFriends),
            progress: [:],
            targetValue: targetDouble,
            unit: unit
        )
        
        Task {
            try? await viewModel.createChallenge(challenge)
            dismiss()
        }
    }
}

// Helper Views
struct SearchResultRow: View {
    let user: Friend
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: user.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray2)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.headline)
            }
            
            Spacer()
            
            Button(action: action) {
                Text("Add")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue1)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
}

struct FriendRow: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: friend.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray2)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            Text(friend.username)
                .font(.subheadline)
        }
    }
}

class ChallengeViewModel: ObservableObject {
    @Published var participants: [Friend] = []
    @Published var averageProgress: Double = 0.0
    @Published var timeRemaining: String = ""
    private var challenge: Challenge?
    private let db = Firestore.firestore()
    
    func setup(with challenge: Challenge) {
        self.challenge = challenge
        fetchParticipants()
        calculateProgress()
        updateTimeRemaining()
    }
    
    func shareChallenge() {
        // Implementation for sharing challenge
        guard let challenge = challenge else { return }
        // Add sharing functionality
    }
    
    func leaveChallenge() {
        guard let challenge = challenge,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        // Remove user from participants
        var updatedParticipants = challenge.participants
        updatedParticipants.removeAll { $0 == userId }
        
        // Update challenge in Firestore
        guard let challengeId = challenge.id else { return }
        db.collection("challenges").document(challengeId).updateData([
            "participants": updatedParticipants
        ]) { error in
            if let error = error {
                print("Error leaving challenge: \(error)")
            }
        }
    }
    
    private func fetchParticipants() {
        guard let challenge = challenge else { return }
        
        for participantId in challenge.participants {
            db.collection("users").document(participantId).getDocument { [weak self] document, error in
                if let document = document,
                   let friend = try? document.data(as: Friend.self) {
                    DispatchQueue.main.async {
                        self?.participants.append(friend)
                    }
                }
            }
        }
    }
    
    private func calculateProgress() {
        guard let challenge = challenge else { return }
        
        let totalProgress = challenge.progress.values.reduce(0.0, +)
        let participantCount = Double(challenge.participants.count)
        
        DispatchQueue.main.async {
            self.averageProgress = totalProgress / participantCount
        }
    }
    
    private func updateTimeRemaining() {
        guard let challenge = challenge else { return }
        
        let endDate = challenge.endDate.dateValue()
        let now = Date()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: now, to: endDate)
        
        if let days = components.day {
            if days < 0 {
                timeRemaining = "Challenge ended"
            } else if days == 0 {
                timeRemaining = "Last day"
            } else if days == 1 {
                timeRemaining = "1 day left"
            } else {
                timeRemaining = "\(days) days left"
            }
        }
    }
}
