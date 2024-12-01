import SwiftUI

struct CalendarView: View {
    @Binding var selectedTab: Int
    @State private var isDailyView: Bool = false
    @StateObject private var dateHolder = DateHolder()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.whitePrimary.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if isDailyView {
                        DailyListView()
                            .environmentObject(dateHolder)
                            .transition(.opacity)
                    } else {
                        MonthlyCalendarView()
                            .environmentObject(dateHolder)
                            .transition(.opacity)
                    }
                }
                .tag(1)
                .animation(.easeInOut, value: isDailyView)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: isDailyView ? "square.grid.2x2.fill" : "line.3.horizontal")
                            .foregroundStyle(.black1)
                            .onTapGesture {
                                withAnimation {
                                    isDailyView.toggle()
                                }
                            }
                            .foregroundStyle(.black1)
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView(selectedTab: .constant(0))
}
