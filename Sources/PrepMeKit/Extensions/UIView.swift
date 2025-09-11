import UIKit

extension UIView {
    
    static func instantiate() -> Self {
        let nib = NSStringFromClass(Self.self).components(separatedBy: ".").last!
        return Bundle.module.loadNibNamed(nib, owner: nil, options: nil)![0] as! Self
    }
    
}
