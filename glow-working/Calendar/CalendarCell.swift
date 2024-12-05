import SwiftUI
import FirebaseFirestore


struct CalendarCell: View {
    @EnvironmentObject var dateHolder: DateHolder // Shared date state across the app
    let count: Int // The cell's index within the calendar
    let startingSpaces: Int // Number of empty spaces at the start of the month grid
    let daysInMonth: Int // Total number of days in the current month
    let daysInPrevMonth: Int // Total days in the previous month
    var dailyLog: DailyLog? // Optional log data specific to this cell
    var onTap: (DailyLog?) -> Void // Callback when the cell is tapped

    var body: some View {
        let (month, _) = monthStruct() // Determine the month and date for this cell


        VStack {
            if month.monthType == .Current {
                if let dailyLog = dailyLog {
                    let progress = dailyLog.totalProgress
                    
                    if progress < 0 {
                        // Display empty circle for negative progress (shouldn't normally occur)
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
                    // Display empty circle for days without logs
                    Circle()
                        .stroke(Color.grayCalendar)
                        .frame(width: 45, height: 45)
                }
            } else {
                // Display for previous/next month cells
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

    /// Determines the text color based on whether the day is in the current month or not
    func textColor(_ type: MonthType) -> Color {
        return type == .Current ? Color.black1 : Color.gray
    }

    /// Calculates the month type and day number for this cell
    /// Returns a tuple containing the Month struct and the actual Date
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
