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
            StatsScreenView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                        .foregroundStyle(.secondary)
                }
                .tag(2)
            HomeScreenView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .foregroundStyle(.secondary)
                }
                .tag(0)
            GoalsView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "document.fill" : "document")
                }
                .tag(3)
            ProfileScreenView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                }
                .tag(4)
        }
        .tint(.selectedTab)
        .ignoresSafeArea()
        .toolbarVisibility(.hidden)
    }
}

#Preview {
    ContentView()
}
