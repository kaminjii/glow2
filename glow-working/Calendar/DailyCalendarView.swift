import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DailyListView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @State private var showEditLog = false
    @State private var logToEdit: DailyLog?
    @State private var dailyLogs: [DailyLog] = []
    
    private let db = Firestore.firestore()
    
    var filteredLogs: [DailyLog] {
        dailyLogs.sorted(by: { $0.date.dateValue() < $1.date.dateValue() })
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
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth),
              let endOfLastDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) else {
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
}

#Preview {
    DailyListView()
        .environmentObject(DateHolder())
}
