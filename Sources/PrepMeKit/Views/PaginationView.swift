import UIKit

class PaginationView: UIStackView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        axis = .horizontal
        spacing = 4
        distribution = .fillEqually
    }
    
    func setup(numberOfPages: Int) {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
        }
        
        for _ in 0..<numberOfPages {
            let view = UIView()
            view.backgroundColor = .scepShade2
            view.layer.cornerRadius = 2
            addArrangedSubview(view)
        }
    }
    
    func setCurrentIndex(_ currentIndex: Int) {
        for (index, view) in arrangedSubviews.enumerated() {
            view.backgroundColor = index <= currentIndex ? .scepAccent : .scepShade2
        }
    }
    
}
