import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        let dateHolder = DateHolder()
        

        
        TabView (selection: $selectedTab){
            CalendarView(selectedTab: $selectedTab)
                .environmentObject(dateHolder)
                .tabItem {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                }
                .tag(1)

            HomeScreenView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .foregroundStyle(.secondary)
                }
                .tag(0)
            StatsScreenView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                        .foregroundStyle(.secondary)
                }
                .tag(2)
        }
        .tint(.selectedTab)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
