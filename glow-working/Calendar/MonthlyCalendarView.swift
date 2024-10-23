import SwiftUI
import FirebaseFirestore

struct MonthlyCalendarView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @FirestoreQuery(collectionPath: "dailyLogs") var dailyLogs: [DailyLog]
    @State private var selectedDate: DailyLog?
    @State private var showEditDay = false

    var body: some View {
        ZStack {
            Color.whitePrimary.edgesIgnoringSafeArea(.all)
                .onTapGesture {
                   selectedDate = nil
               }
            
            VStack(spacing: 1) {
                Image(systemName: "line.3.horizontal")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, 20)
                
                DateScrollView()
                    .environmentObject(dateHolder)
                
                dayOfWeekStack
                
                calendarGrid
                    .padding(.bottom)
                
                if let selectedDate = selectedDate {
                    SelectedDayInfoCell(
                        date: selectedDate.date.dateValue(),
                        progress: selectedDate.totalPercentCompleted,
                        note: selectedDate.note!,
                        dailyLog: selectedDate,
                        showEditDay: $showEditDay
                    )
                    .transition(.slide)
                    .fullScreenCover(isPresented: $showEditDay) {
                        EditExistingDayView(date: selectedDate.date.dateValue(), onSave: { updatedLog in
                            print(updatedLog)
                            self.selectedDate = updatedLog
                        })
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    var dayOfWeekStack: some View {
        HStack(spacing: 1) {
            Text("Sun").dayOfWeek()
            Text("Mon").dayOfWeek()
            Text("Tue").dayOfWeek()
            Text("Wed").dayOfWeek()
            Text("Thu").dayOfWeek()
            Text("Fri").dayOfWeek()
            Text("Sat").dayOfWeek()
        }
        .padding(.top, 30)
    }
    
    var calendarGrid: some View {
        VStack(spacing: 1) {
            let daysInMonth = CalendarHelper().daysInMonth(dateHolder.date)
            let firstDayofMonth = CalendarHelper().firstDayOfMonth(dateHolder.date)
            let startingSpaces = CalendarHelper().weekDay(firstDayofMonth)
            let prevMonth = CalendarHelper().minusMonth(dateHolder.date)
            let daysInPrevMonth = CalendarHelper().daysInMonth(prevMonth)
            
            ForEach(0..<6) { row in
                HStack(spacing: 1) {
                    ForEach(1..<8) { column in
                        let count = column + row * 7
                        
                        let currentDay = count - startingSpaces
                        let isWithinCurrentMonth = (currentDay > 0 && currentDay <= daysInMonth)

                        let day = isWithinCurrentMonth ? currentDay : nil
                        let date = dateForDay(currentDay: day, in: dateHolder.date)

                        let logForDay = dailyLogs.first { Calendar.current.isDate($0.date.dateValue(), inSameDayAs: date) }
                        
                        CalendarCell(
                            count: count,
                            startingSpaces: startingSpaces,
                            daysInMonth: daysInMonth,
                            daysInPrevMonth: daysInPrevMonth,
                            dailyLog: logForDay
                        ) { log in
                            selectedDate = log
                        }
                    }
                }
            }
        }
    }

    func dateForDay(currentDay: Int?, in date: Date) -> Date {
        guard let day = currentDay else {
            return date
        }
        var components = Calendar.current.dateComponents([.year, .month], from: date)
        components.day = day
        return Calendar.current.date(from: components)!
    }
}

#Preview {
    MonthlyCalendarView()
        .environmentObject(DateHolder())
}

extension Text {
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .font(.footnote)
            .padding(.vertical)
            .lineLimit(1)
    }
}
