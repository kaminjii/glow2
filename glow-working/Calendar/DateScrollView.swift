import SwiftUI

struct DateScrollView: View {
    @EnvironmentObject var dateHolder: DateHolder
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black1)
            }
            
            Text(CalendarHelper().monthYearString(dateHolder.date))
                .font(.title3).bold()
                .animation(.none)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black1)
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.black1)
            }
            
            Spacer()
        }
    }
    
    func previousMonth() {
        dateHolder.date = CalendarHelper().minusMonth(dateHolder.date)
    }
    
    func nextMonth() {
        dateHolder.date = CalendarHelper().plusMonth(dateHolder.date)
    }
}

#Preview {
    DateScrollView()
        .environmentObject(DateHolder())
}
