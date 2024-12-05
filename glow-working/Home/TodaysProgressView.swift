import SwiftUI

// View displaying today's progress, including overall progress and a notes section
struct TodaysProgressView: View {
    @StateObject private var viewModel = TodaysProgressViewModel() // ViewModel for managing data and logic.
    @Environment(\.dismiss) var dismiss // Environment variable to handle dismissing the view.
    @Binding var note: String // Binding to update the note in the parent view.
    @State private var contentHeight: CGFloat = 0 // State to manage dynamic height adjustments.
    @State private var localNote: String = ""  // Local state to manage note text
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                // Scrollable content area for progress and note sections.
                ScrollView {
                    VStack(spacing: 24) {
                        progressCard // Section displaying progress
                        noteSection  // Section for adding or editing notes
                        Spacer(minLength: 40) // Spacer for layout adjustment
                    }
                    .padding()
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView() // Activity indicator
                                .tint(.white)
                        )
                }
            }
            .navigationBarTitleDisplayMode(.inline) // Inline navigation bar style
            .toolbar { // Toolbar items for cancel and done
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.note = localNote  // Update viewModel with local note
                        note = localNote  // Update parent view's note
                        viewModel.saveProgress() // Save current progress
                        dismiss() // Dismiss view when done is tapped
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .principal) {
                    // Central toolbar title
                    Text("Today's Progress")
                        .font(.headline)
                }
            }
        }
        .onAppear {
            viewModel.fetchTodayLog() // Fetch today's log
            localNote = note  // Initialize local note with passed in note
        }
    }
    
    // A card view displaying overall progress with a progress bar
    private var progressCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overall Progress")
                    .font(.headline)
                    .foregroundStyle(.black1)
                
                HStack {
                    ProgressBar(progress: viewModel.progress) // Custom progress bar view
                    Text("\(Int(viewModel.progress * 100))%") // Display progress as a percentage
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray1)
                        .frame(width: 50)
                }
            }
            
            Divider()
            
            Text("Complete your daily goals to increase your overall progress")
                .font(.subheadline)
                .foregroundStyle(.gray1)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
    
    // A section for users to write or edit notes
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes") // Section title
                .font(.headline)
                .foregroundStyle(.black1)
            
            NoteTextEditor(note: $localNote, originalNote: .constant(""))  // Use localNote instead
                .frame(minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .blackShadow, radius: 10, y: 5)
                )
        }
    }
}

#Preview {
    TodaysProgressView(note: .constant("Sample note for preview"))
}
