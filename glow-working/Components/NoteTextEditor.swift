import SwiftUI

struct NoteTextEditor: View {
    @Binding var note: String
    @Binding var originalNote: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $note)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray3, lineWidth: 1.5))

            if note.isEmpty {
                Text("Add note...")
                    .foregroundColor(.gray)
                    .padding(15)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 125)
    }
}

#Preview {
    NoteTextEditor(note: .constant(" hello "), originalNote: .constant("hello"))
}
