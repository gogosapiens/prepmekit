import UIKit

class QuizNavigationButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }
    
    override var isEnabled: Bool {
        didSet {
            update()
        }
    }
    
    var isActive: Bool = false {
        didSet {
            update()
        }
    }
    
    private func update() {
        let borderColor: UIColor
        let borderWidth: CGFloat
        let tintColor: UIColor
        
        if !isEnabled {
            borderColor = .clear
            borderWidth = 0
            tintColor = .scepTextColor
        } else if isActive {
            borderColor = .prepMeAccent
            borderWidth = 1
            tintColor = .prepMeAccent
        } else {
            borderColor = .scepShade2
            borderWidth = 1
            tintColor = .scepTextColor
        }
        
        
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        self.tintColor = tintColor
    }
    
}
