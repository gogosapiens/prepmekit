import UIKit
import SCEPKit

class ResultPageButton: UIButton {
    
    private let stackView = UIStackView()
    private let indicatorView = UIView()
    
    let pageTitleLabel = UILabel()
    let pageSubtitleLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        pageTitleLabel.font = SCEPKit.font(ofSize: 12, weight: .medium)
        pageTitleLabel.textColor = .scepTextColor
        pageTitleLabel.textAlignment = .center
        stackView.addArrangedSubview(pageTitleLabel)
        
        pageSubtitleLabel.font = SCEPKit.font(ofSize: 24, weight: .bold)
        pageSubtitleLabel.textColor = .scepTextColor
        pageSubtitleLabel.textAlignment = .center
        stackView.addArrangedSubview(pageSubtitleLabel)
        
        indicatorView.backgroundColor = .clear
        stackView.addArrangedSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: 4)
        ])
        
        update()
    }
    
    var isActive: Bool = false {
        didSet {
            update()
        }
    }
    
    private func update() {
        pageTitleLabel.textColor = isActive ? .scepTextColor : .scepShade1
        pageSubtitleLabel.textColor = isActive ? .scepTextColor : .scepShade1
        indicatorView.backgroundColor = isActive ? .prepMeAccent : .clear
    }
    
}
