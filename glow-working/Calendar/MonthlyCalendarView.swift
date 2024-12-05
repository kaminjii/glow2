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

            VStack(spacing: 0) {
                // Calendar Header
                DateScrollView()
                    .environmentObject(dateHolder)
                    .padding(.horizontal)
                
                VStack(spacing: 20) {
                    // Days of Week Header
                    dayOfWeekStack
                    
                    // Calendar Grid
                    calendarGrid
                        .padding(.horizontal, 8)
                    
                    // Selected Date Card
                    if let selectedDate = selectedDate {
                        DayCard(
                            date: selectedDate.date.dateValue(),
                            progress: selectedDate.totalProgress,
                            note: selectedDate.note ?? "",
                            dailyLog: selectedDate,
                            showEditDay: $showEditDay
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal)
                        .fullScreenCover(isPresented: $showEditDay, onDismiss: {
                            fetchDailyLogs()  // Refresh data when sheet is dismissed
                        }) {
                            EditExistingDayView(date: selectedDate.date.dateValue(), onSave: { updatedLog in
                                self.selectedDate = updatedLog
                            })
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .background(Color.whitePrimary.opacity(0.97))
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedDate = nil
                }
            }
        }
        .onAppear {
            fetchDailyLogs()
        }
        .onChange(of: dateHolder.date) { oldDate, newDate in
            fetchDailyLogs()
        }
    }
    
    var dayOfWeekStack: some View {
        HStack(spacing: 1) {
            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 8)
    }
    
    var calendarGrid: some View {
        let daysInMonth = CalendarHelper().daysInMonth(dateHolder.date)
        let firstDayofMonth = CalendarHelper().firstDayOfMonth(dateHolder.date)
        let startingSpaces = CalendarHelper().weekDay(firstDayofMonth)
        let prevMonth = CalendarHelper().minusMonth(dateHolder.date)
        let daysInPrevMonth = CalendarHelper().daysInMonth(prevMonth)
        
        return VStack(spacing: 2) {
            ForEach(0..<6) { row in
                HStack(spacing: 2) {
                    ForEach(1..<8) { column in
                        let count = column + row * 7
                        let position = count - startingSpaces
                        
                        Group {
                            if position <= 0 {
                                createCalendarCell(
                                    count: count,
                                    day: daysInPrevMonth + position,
                                    inMonth: prevMonth,
                                    monthType: .Previous
                                )
                            } else if position > daysInMonth {
                                createCalendarCell(
                                    count: count,
                                    day: position - daysInMonth,
                                    inMonth: CalendarHelper().plusMonth(dateHolder.date),
                                    monthType: .Next
                                )
                            } else {
                                createCalendarCell(
                                    count: count,
                                    day: position,
                                    inMonth: dateHolder.date,
                                    monthType: .Current
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Keep existing helper functions unchanged
    private func createCalendarCell(count: Int, day: Int, inMonth: Date, monthType: MonthType) -> some View {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month], from: inMonth)
        dateComponents.day = day
        
        let date = calendar.date(from: dateComponents)!
        let startOfDay = calendar.startOfDay(for: date)
        
        let logForDay = dailyLogs.first { log in
            let logDate = log.date.dateValue()
            let logStartOfDay = calendar.startOfDay(for: logDate)
            return logStartOfDay == startOfDay
        }
        
        return CalendarCell(
            count: count,
            startingSpaces: CalendarHelper().weekDay(CalendarHelper().firstDayOfMonth(dateHolder.date)),
            daysInMonth: CalendarHelper().daysInMonth(dateHolder.date),
            daysInPrevMonth: CalendarHelper().daysInMonth(CalendarHelper().minusMonth(dateHolder.date)),
            dailyLog: logForDay
        ) { log in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedDate = log
            }
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


    private func dateForDay(_ day: Int, in date: Date) -> Date {
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
