import SwiftUI
import FirebaseCore

// A card view that displays a daily progress entry with a star rating, date, and notes
struct DayCard: View {
    var date: Date
    var progress: Double
    var note: String
    var dailyLog: DailyLog
    @Binding var showEditDay: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Star and date section
                VStack(spacing: 4) {
                    Image(starImage(for: progress))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                    Text(formattedDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black1)
                }
                .frame(width: 65)
                
                // Vertical divider
                Rectangle()
                    .fill(Color.gray2)
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 12)
                
                // Right section: Progress percentage, edit button, and notes
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(Int(progress * 100))% Complete")
                            .font(.headline)
                            .foregroundStyle(.black1)
                        
                        Spacer()
                        
                        Button(action: {
                            showEditDay = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.medium)
                                .foregroundStyle(.gray1)
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                    }
                    
                    // Only show notes if they exist
                    if !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.gray1)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.trailing, 4)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .blackShadow, radius: 10, y: 5)
        )
    }
    
    // Formats the date to show month and day (e.g., "Dec 5")
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func starImage(for progress: Double) -> String {
        switch progress {
        case 0..<0.2:
            return "star5"
        case 0.2..<0.4:
            return "star4"
        case 0.4..<0.6:
            return "star3"
        case 0.6..<0.8:
            return "star2"
        case 0.8...1.0:
            return "star1"
        default:
            return "star5"
        }
    }
}

#Preview {
    let sampleDailyLog = DailyLog(
        id: UUID().uuidString,
        date: Timestamp(date: Date()),
        note: "Completed most of the tasks today!",
        totalProgress: 0.75
    )
    
    DayCard(
        date: sampleDailyLog.date.dateValue(),
        progress: sampleDailyLog.totalProgress,
        note: sampleDailyLog.note!,
        dailyLog: sampleDailyLog,
        showEditDay: .constant(false)
    )
}
