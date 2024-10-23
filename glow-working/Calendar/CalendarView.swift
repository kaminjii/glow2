import SwiftUI

struct CalendarView: View {
    @Binding var selectedTab: Int
    @State private var isDailyView: Bool = false

    var body: some View {
        VStack {
            Image(systemName: isDailyView ? "square.grid.2x2.fill" : "line.3.horizontal")
                .onTapGesture {
                    withAnimation {
                        isDailyView.toggle()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .frame(height: 5)
                .foregroundStyle(.black1)
                .padding(.horizontal)

            if isDailyView {
                DailyListView()
                    .environmentObject(DateHolder())
                    .transition(.opacity)
            } else {
                MonthlyCalendarView()
                    .environmentObject(DateHolder())
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isDailyView)
    }
}

#Preview {
    CalendarView(selectedTab: .constant(0))
}
