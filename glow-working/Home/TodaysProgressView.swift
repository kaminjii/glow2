import SwiftUI

struct TodaysProgressView: View {
    @StateObject private var viewModel = TodaysProgressViewModel()
    @Environment(\.dismiss) var dismiss
    @Binding var note: String
    @State private var contentHeight: CGFloat = 0
    @State private var localNote: String = ""  // Local state to manage note text
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        progressCard
                        noteSection
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.note = localNote  // Update viewModel with local note
                        note = localNote  // Update parent view's note
                        viewModel.saveProgress()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .principal) {
                    Text("Today's Progress")
                        .font(.headline)
                }
            }
        }
        .onAppear {
            viewModel.fetchTodayLog()
            localNote = note  // Initialize local note with passed in note
        }
    }
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overall Progress")
                    .font(.headline)
                    .foregroundStyle(.black1)
                
                HStack {
                    ProgressBar(progress: viewModel.progress)
                    Text("\(Int(viewModel.progress * 100))%")
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
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
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
