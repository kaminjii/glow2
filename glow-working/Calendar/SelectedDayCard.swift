import SwiftUI
import FirebaseCore

struct SelectedDayCard: View {
    var date: Date
    var progress: Double
    var note: String
    var dailyLog: DailyLog

    @Binding var showEditDay: Bool

    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 4) {
                    Image(starImage(for: progress))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(.black1)
                }
                
                Divider()
                    .background(Color.gray1)
                    .frame(width: 10)
                    .padding(.vertical)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("\(Int(progress * 100))% Complete")
                            .foregroundStyle(.black1)
                        
                        Spacer()
                        
                        Button(action: {
                            showEditDay = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                                .foregroundStyle(.gray1)
                        }
                    }
                    
                    Text("\(note)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.gray1)
                        .font(.subheadline)
                    
                    Spacer()
                }
                .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .shadow(color: .blackShadow, radius: 10, y: 5)
    }

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
        totalPercentCompleted: 0.75
    )
    
    SelectedDayCard(
        date: sampleDailyLog.date.dateValue(),
        progress: sampleDailyLog.totalPercentCompleted,
        note: sampleDailyLog.note!,
        dailyLog: sampleDailyLog,
        showEditDay: .constant(false)
    )
}
