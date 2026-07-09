import UIKit

extension UIView {
    
    static func instantiate() -> Self {
        let nib = NSStringFromClass(Self.self).components(separatedBy: ".").last!
        let view = Bundle.module.loadNibNamed(nib, owner: nil, options: nil)![0] as! Self
        view.overrideUserInterfaceStyle = .light
        return view
    }
    
}
