import SwiftUI
import FirebaseFirestore

struct DailyListView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @FirestoreQuery(collectionPath: "dailyLogs") var dailyLogs: [DailyLog]
    @State private var showEditLog = false
    @State private var logToEdit: DailyLog?

    var filteredLogs: [DailyLog] {
        let calendar = Calendar.current
        return dailyLogs.filter { log in
            let logDate = log.date.dateValue()
            return calendar.isDate(logDate, equalTo: dateHolder.date, toGranularity: .month)
        }.sorted(by: { $0.date.dateValue() < $1.date.dateValue() })
    }

    var body: some View {
        ZStack {
            Color.whitePrimary.edgesIgnoringSafeArea(.all)

            VStack {
                
                DateScrollView()
                    .environmentObject(dateHolder)
                    .padding(.horizontal)

                List {
                    if filteredLogs.isEmpty {
                        // Show message if there are no logs for the month
                        Text("No entries for this month")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredLogs) { log in
                            Section {
                                DayCard(
                                    date: log.date.dateValue(),
                                    progress: log.totalProgress,
                                    note: log.note ?? "No notes",
                                    dailyLog: log,
                                    showEditDay: $showEditLog
                                )
                                .padding(.bottom, 0)
                                .listRowSeparator(.hidden)
                                .listRowSpacing(0)
                                .listRowBackground(Color.whitePrimary)
                                .onTapGesture {
                                    logToEdit = log
                                    showEditLog = true
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .fullScreenCover(item: $logToEdit) { log in
                EditExistingDayView(date: log.date.dateValue(), onSave: { _ in })
            }
        }
    }
}

#Preview {
    DailyListView()
        .environmentObject(DateHolder())
}
