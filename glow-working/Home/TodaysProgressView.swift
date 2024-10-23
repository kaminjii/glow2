import SwiftUI

struct TodaysProgressView: View {
    @StateObject private var viewModel = TodaysProgressViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Binding var note: String
    
    var body: some View {
        ZStack {
            Color.whitePrimary
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                headerView
                progressSection
                noteTextEditor
                imagePicker
                saveButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal)
            .navigationTitle("Today's Progress")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isPickerPresented) {
                PhotoPicker(selectedImage: $viewModel.selectedImage)
            }
        }
        .onAppear {
            viewModel.fetchTodayLog()
        }
    }
    
    private var headerView: some View {
        ZStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            Text("Today's Progress")
                .bold()
        }
    }
    
    private var progressSection: some View {
        HStack {
            ProgressBar(progress: viewModel.progress)
            Text("\(Int(viewModel.progress * 100))%")
                .font(.body)
                .foregroundStyle(.gray1)
                .frame(width: 50)
        }
    }
    
    private var noteTextEditor: some View {
        NoteTextEditor(note: $note, originalNote: $viewModel.note)
    }

    
    private var imagePicker: some View {
        ImagePicker(selectedImage: $viewModel.selectedImage, isPickerPresented: $viewModel.isPickerPresented)
    }

    
    private var saveButton: some View {
        GradientButton(title: "Save", action: {
            viewModel.saveProgress()
            presentationMode.wrappedValue.dismiss()
        }, isEnabled: true)
    }
}

#Preview {
    TodaysProgressView(note: .constant("gelloo"))
}
