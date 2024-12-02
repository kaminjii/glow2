import SwiftUI

struct TodaysProgressView: View {
    @StateObject private var viewModel = TodaysProgressViewModel()
    @Environment(\.dismiss) var dismiss
    @Binding var note: String
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whitePrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        progressCard
                        noteSection
                        photoSection
                        Spacer(minLength: 40)
                    }
                    .padding()
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
            .sheet(isPresented: $viewModel.isPickerPresented) {
                PhotoPicker(selectedImage: $viewModel.selectedImage)
            }
        }
        .onAppear {
            viewModel.fetchTodayLog()
        }
    }
    
    // Progress card displaying overall progress percentage
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
    
    
    // Note-taking section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .foregroundStyle(.black1)
            
            NoteTextEditor(note: $note, originalNote: $viewModel.note)
                .frame(minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .blackShadow, radius: 10, y: 5)
                )
        }
    }
    
    // Photo upload section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(.headline)
                .foregroundStyle(.black1)
            
            ImagePicker(
                selectedImage: $viewModel.selectedImage,
                isPickerPresented: $viewModel.isPickerPresented
            )
            .frame(minHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .blackShadow, radius: 10, y: 5)
            )
            
            if viewModel.selectedImage == nil {
                Text("Add a photo to track your progress")
                    .font(.subheadline)
                    .foregroundStyle(.gray1)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    TodaysProgressView(note: .constant("Sample note for preview"))
}
