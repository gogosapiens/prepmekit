import UIKit
import SCEPKit

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var weekdayLabel: UILabel!
    @IBOutlet private weak var dayView: UIView!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var indicatorView: UIView!
    
    func setup(date: Date, indicatorColor: UIColor, isSelected: Bool) {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            weekdayLabel.text = "Today"
        } else {
            let weekday = calendar.component(.weekday, from: date) - 1
            weekdayLabel.text = calendar.shortWeekdaySymbols[weekday]
        }
        dayLabel.text = String(calendar.component(.day, from: date))
        dayView.layer.borderColor = UIColor.scepTextColor.cgColor
        dayView.layer.borderWidth = isSelected ? 1 : 0
        weekdayLabel.textColor = isSelected ? .scepTextColor : .scepShade1
        dayLabel.textColor = isSelected || indicatorColor != .clear ? .scepTextColor : .scepShade1
        indicatorView.backgroundColor = indicatorColor
    }
    
}
