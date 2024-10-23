import SwiftUI

struct CalendarView: View {
    var body: some View {
        let dateHolder = DateHolder()
        MonthlyCalendarView()
            .environmentObject(dateHolder)
    }
}

#Preview {
    CalendarView()
}
