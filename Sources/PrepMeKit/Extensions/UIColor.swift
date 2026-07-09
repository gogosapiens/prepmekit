import UIKit

extension UIColor {
    
    static let prepMeAccent = UIColor(resource: .prepMeAccent)
    static let prepMeTextColor = UIColor(hex: 0x1D1E21)
    static let prepMeShade1 = UIColor(hex: 0x9599A3)
    static let prepMeShade2 = UIColor(hex: 0xD0D6E5)
    static let prepMeShade3 = UIColor(hex: 0xF4F5F9)
    
    convenience init(hex: UInt64, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init?(hex: String, alpha: CGFloat = 1) {
        var hexValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&hexValue) else { return nil }
        self.init(hex: hexValue)
    }
    
}
