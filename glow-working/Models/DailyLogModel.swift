import FirebaseFirestore

struct DailyLog: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Timestamp
    var image: String?
    var note: String?
    var totalPercentCompleted: Double = 0.0
}
