import SwiftUI

struct CalendarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        let dateHolder = DateHolder()
        MonthlyCalendarView()
            .environmentObject(dateHolder)
    }
}

#Preview {
    CalendarView(selectedTab: .constant(1))
}
