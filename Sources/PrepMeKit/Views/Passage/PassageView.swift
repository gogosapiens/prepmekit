import UIKit

@MainActor
protocol PassageViewDelegate: AnyObject {
    func passageView(_ passageView: PassageView, open image: UIImage)
}

class PassageView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var trailingIndicatorImageView: UIImageView!
    @IBOutlet private weak var passageWebView: WebView!
    @IBOutlet private weak var passageImageView: UIImageView!
    @IBOutlet private weak var passageImageWebView: WebView!
    @IBOutlet private weak var collapsePassageImageDescriptionButton: UIButton!
    @IBOutlet private weak var passageImageDescriptionWebView: WebView!
    private let tapGesture = UITapGestureRecognizer()
    private let tapImageGesture = UITapGestureRecognizer()
    private var passage: String?
    private var passageLabel: String?
    private var passageImage: Question.Image?
    private var loadPassageImageTask: Task<Void, Error>?
    private var isOpen = false
    
    weak var delegate: PassageViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
        tapImageGesture.addTarget(self, action: #selector(didTapImage))
        passageImageView.addGestureRecognizer(tapImageGesture)
        passageWebView.setFont(size: 16, weight: .medium)
        passageImageWebView.setFont(size: 14, weight: .medium)
        passageImageDescriptionWebView.setFont(size: 14, weight: .medium)
    }
    
    @objc private func didTap() {
        isOpen.toggle()
        if let passage, !passage.isEmpty {
            passageWebView.isHidden.toggle()
        }
        if let passageImage {
            passageImageView.isHidden.toggle()
            if !passageImage.altText.isEmpty {
                passageImageWebView.isHidden.toggle()
            }
            if !passageImage.longAltText.isEmpty {
                collapsePassageImageDescriptionButton.isHidden.toggle()
                if collapsePassageImageDescriptionButton.isHidden {
                    passageImageDescriptionWebView.isHidden = true
                }
                updateCollapsePassageImageDescriptionButton()
            }
        }
        updateTitle()
    }
    
    @objc private func didTapImage() {
        guard let image = passageImageView.image else { return }
        delegate?.passageView(self, open: image)
    }
    
    func setup(
        passage: String?,
        passageLabel: String?,
        passageImage: Question.Image?
    ) {
        self.passage = passage
        self.passageLabel = passageLabel
        self.passageImage = passageImage
        isOpen = false
        
        updateTitle()
        
        if let passage, !passage.isEmpty {
            passageWebView.isHidden = false
            passageWebView.setContent(passage)
        } else {
            passageWebView.isHidden = true
        }
        
        if let passageImage, let url = URL(string: "https://avirtek.mobi/" + passageImage.url) {
            loadPassageImage(url: url)
            if !passageImage.altText.isEmpty {
                passageImageWebView.setContent(passageImage.altText)
            }
            if !passageImage.longAltText.isEmpty {
                passageImageDescriptionWebView.setContent(passageImage.longAltText)
            }
        }
        
        trailingIndicatorImageView.image = UIImage(resource: .chevronDown)
        passageWebView.isHidden = true
        passageImageView.isHidden = true
        passageImageWebView.isHidden = true
        collapsePassageImageDescriptionButton.isHidden = true
        passageImageDescriptionWebView.isHidden = true
    }
    
    private func loadPassageImage(url: URL) {
        loadPassageImageTask?.cancel()
        passageImageView.image = nil
        loadPassageImageTask = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            passageImageView.image = UIImage(data: data)
        }
    }
    
    @IBAction private func collapseExplanationImageDescriptionButtonClicked(_ sender: Any) {
        passageImageDescriptionWebView.isHidden.toggle()
        updateCollapsePassageImageDescriptionButton()
    }
    
    private func updateTitle() {
        var elements = [String]()
        if let passageLabel, !passageLabel.isEmpty {
            elements.append(passageLabel)
        } else if let passage, !passage.isEmpty {
            elements.append("Passage")
        }
        if passageImage != nil {
            elements.append("Image")
        }
        
        titleLabel.text = (isOpen ? "Hide" : "Show") + " " + elements.joined(separator: " + ")
        trailingIndicatorImageView.image = UIImage(resource: isOpen ? .chevronUp : .chevronDown)
    }
    
    private func updateCollapsePassageImageDescriptionButton() {
        collapsePassageImageDescriptionButton.setImage(UIImage(resource: passageImageDescriptionWebView.isHidden ? .smallChevronDown : .smallChevronUp), for: .normal)
    }
    
}
