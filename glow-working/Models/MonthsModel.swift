import Foundation

struct Month {
    var monthType: MonthType
    var dayInt: Int
    func dayString() -> String {
        String(dayInt)
    }
}

enum MonthType {
    case Previous
    case Current
    case Next
}
