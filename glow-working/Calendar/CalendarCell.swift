import SwiftUI
import FirebaseFirestore

struct CalendarCell: View {
    @EnvironmentObject var dateHolder: DateHolder
    let count: Int
    let startingSpaces: Int
    let daysInMonth: Int
    let daysInPrevMonth: Int
    var dailyLog: DailyLog? // Passed from parent, specific to this cell
    var onTap: (DailyLog?) -> Void

    var body: some View {
        let (month, _) = monthStruct()

        VStack {
            if month.monthType == .Current {
                if let dailyLog = dailyLog {
                    let progress = dailyLog.totalProgress
                    
                    if progress < 0 {
                        Circle()
                            .stroke(Color.grayCalendar)
                            .frame(width: 45, height: 45)
                    } else {
                        let starImageName = starImage(for: progress)
                        Image(starImageName) 
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .onTapGesture {
                                onTap(dailyLog)
                            }
                    }
                } else {
                    Circle()
                        .stroke(Color.grayCalendar)
                        .frame(width: 45, height: 45)
                }
            } else {
                Circle()
                    .stroke(Color.grayCalendar)
                    .fill(Color.grayCalendarFill)
                    .frame(width: 45, height: 45)
            }

            Text(month.dayString())
                .foregroundStyle(textColor(month.monthType))
                .font(.system(size: 9))
        }
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
    }

    func textColor(_ type: MonthType) -> Color {
        return type == .Current ? Color.black1 : Color.gray
    }

    func monthStruct() -> (Month, Date) {
        let dayInt: Int
        let monthType: MonthType
        
        // Calculate position in the month
        let position = count - startingSpaces
        
        if position <= 0 {
            // Previous month
            dayInt = daysInPrevMonth + position
            monthType = .Previous
        } else if position > daysInMonth {
            // Next month
            dayInt = position - daysInMonth
            monthType = .Next
        } else {
            // Current month
            dayInt = position
            monthType = .Current
        }
        
        let month = Month(monthType: monthType, dayInt: dayInt)
        let date = dateForCurrentDay(month: month)
        
        return (month, date)
    }
    
    func dateForCurrentDay(month: Month) -> Date {
        let currentMonthDate = dateHolder.date
        var components = Calendar.current.dateComponents([.year, .month], from: currentMonthDate)
        
        components.day = month.dayInt
        
        return Calendar.current.date(from: components)!
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
    CalendarCell(count: 1, startingSpaces: 1, daysInMonth: 1, daysInPrevMonth: 1, dailyLog: nil, onTap: {_ in })
        .environmentObject(DateHolder())
}
