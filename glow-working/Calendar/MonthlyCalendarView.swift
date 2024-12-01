import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MonthlyCalendarView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @State private var selectedDate: DailyLog?
    @State private var showEditDay = false
    @State private var dailyLogs: [DailyLog] = []
    
    private let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color.whitePrimary.edgesIgnoringSafeArea(.all)

            VStack(spacing: 1) {
                DateScrollView()
                    .environmentObject(dateHolder)
                
                dayOfWeekStack
                
                calendarGrid
                    .padding(.bottom)
                
                if let selectedDate = selectedDate {
                    DayCard(
                        date: selectedDate.date.dateValue(),
                        progress: selectedDate.totalProgress,
                        note: selectedDate.note ?? "",
                        dailyLog: selectedDate,
                        showEditDay: $showEditDay
                    )
                    .transition(.slide)
                    .fullScreenCover(isPresented: $showEditDay) {
                        EditExistingDayView(date: selectedDate.date.dateValue(), onSave: { updatedLog in
                            self.selectedDate = updatedLog
                        })
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .onTapGesture {
               selectedDate = nil
            }
        }
        .onAppear {
            fetchDailyLogs()
        }
        .onChange(of: dateHolder.date) { oldDate, newDate in
            fetchDailyLogs()
        }
    }
    
    private func fetchDailyLogs() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }
        
        // Get the start and end of the month
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: dateHolder.date)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return
        }
        
        // Create end of day by setting time to 23:59:59
        guard let endOfLastDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) else {
            return
        }
        
        print("Fetching logs between \(startOfMonth) and \(endOfLastDay)")
        
        db.collection("users").document(userId).collection("dailyLogs")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: endOfLastDay))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching daily logs: \(error)")
                    return
                }
                
                print("Found \(snapshot?.documents.count ?? 0) documents")
                
                self.dailyLogs = snapshot?.documents.compactMap { document in
                    if let log = try? document.data(as: DailyLog.self) {
                        print("Successfully parsed log for date: \(log.date.dateValue()), progress: \(log.totalProgress)")
                        return log
                    } else {
                        print("Failed to parse document: \(document.data())")
                        return nil
                    }
                } ?? []
                
                print("Final parsed logs count: \(self.dailyLogs.count)")
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

                        let logForDay = dailyLogs.first {
                            Calendar.current.isDate($0.date.dateValue(), inSameDayAs: date)
                        }

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
        guard let day = currentDay else { return date }
        var components = Calendar.current.dateComponents([.year, .month], from: date)
        components.day = day
        return Calendar.current.date(from: components)!
    }
}

extension Text {
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .font(.footnote)
            .padding(.vertical)
            .lineLimit(1)
    }
}

#Preview {
    MonthlyCalendarView()
        .environmentObject(DateHolder())
}
