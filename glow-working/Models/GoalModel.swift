import FirebaseFirestore

struct Goal: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Timestamp
    var deleted: Bool = false
    var detail: String?
    var icon: String
    var name: String
    var quantityComplete: Double
    var quantityGoal: Double
    var unit: String
    
}
