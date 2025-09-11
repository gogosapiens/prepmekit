import UIKit

@MainActor
protocol ResultHeaderViewDelegate: AnyObject {
    func resultHeaderViewRetakeQuiz(_ resultHeaderView: ResultHeaderView)
    func resultHeaderViewAllPage(_ resultHeaderView: ResultHeaderView)
    func resultHeaderViewIncorrectPage(_ resultHeaderView: ResultHeaderView)
    func resultHeaderViewCorrectPage(_ resultHeaderView: ResultHeaderView)
}

class ResultHeaderView: UIView {
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var correctAnswersView: UIView!
    @IBOutlet private weak var correctAnswersLabel: UILabel!
    @IBOutlet private weak var quizTimeView: UIView!
    @IBOutlet private weak var quizTimeLabel: UILabel!
    @IBOutlet private weak var communityScoreLabel: UILabel!
    @IBOutlet private weak var allPageButton: ResultPageButton!
    @IBOutlet private weak var incorrectPageButton: ResultPageButton!
    @IBOutlet private weak var correctPageButton: ResultPageButton!
    
    weak var delegate: ResultHeaderViewDelegate?
    
    func setup(with quizResult: QuizResult) {
        dateLabel.text = quizResult.date.formatted(date: .numeric, time: .shortened)
        
        let progress = Int(Double(quizResult.correctAnswerCount) / Double(quizResult.questions.count) * 100)
        setupProgress(CGFloat(progress), point: CGFloat(quizResult.communityScore), color: UIColor(hex: progress >= quizResult.communityScore ? 0x049775 : 0xDD0000))
        progressLabel.text = String(progress) + "%"
        
        let infoBackgroundColor = UIColor(hex: progress >= quizResult.communityScore ? 0xE6F8F4 : 0xFFEEEE)
        correctAnswersView.backgroundColor = infoBackgroundColor
        quizTimeView.backgroundColor = infoBackgroundColor
        
        correctAnswersLabel.text = String(quizResult.correctAnswerCount) + "/" + String(quizResult.questions.count)
        
        let minutes = quizResult.duration / 60
        let seconds = quizResult.duration % 60
        var timeComponents = [String]()
        if minutes > 0 {
            timeComponents.append(String(minutes) + "m")
        }
        timeComponents.append(String(seconds) + "s")
        quizTimeLabel.text = timeComponents.joined(separator: " ")
        
        communityScoreLabel.text = String(quizResult.communityScore) + "% Community Score"
        
        allPageButton.pageTitleLabel.text = "All"
        allPageButton.pageSubtitleLabel.text = String(quizResult.questions.count)
        allPageButton.isActive = true
        
        incorrectPageButton.pageTitleLabel.text = "Incorrect"
        incorrectPageButton.pageSubtitleLabel.text = String(quizResult.questions.count - quizResult.correctAnswerCount)
        
        correctPageButton.pageTitleLabel.text = "Correct"
        correctPageButton.pageSubtitleLabel.text = String(quizResult.correctAnswerCount)
    }
    
    private func setupProgress(_ progress: CGFloat, point: CGFloat, color: UIColor) {
        let lineWidth: CGFloat = 18
        
        let placeholderLayer = CAShapeLayer()
        placeholderLayer.frame = progressView.bounds
        let path = UIBezierPath(arcCenter: CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height - lineWidth / 2), radius: progressView.bounds.height - lineWidth, startAngle: -.pi, endAngle: 0, clockwise: true).cgPath
        placeholderLayer.path = path
        placeholderLayer.strokeColor = UIColor.scepShade3.cgColor
        placeholderLayer.lineWidth = lineWidth
        placeholderLayer.fillColor = UIColor.clear.cgColor
        placeholderLayer.lineCap = .round
        
        let progressLayer = CAShapeLayer()
        progressLayer.frame = progressView.bounds
        progressLayer.path = path
        progressLayer.strokeColor = color.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress / 100
        
        let pointLayer = CAShapeLayer()
        pointLayer.frame = progressView.bounds
        pointLayer.path = path
        pointLayer.strokeColor = UIColor.scepTextColor.cgColor
        pointLayer.lineWidth = 11
        pointLayer.fillColor = UIColor.clear.cgColor
        pointLayer.lineCap = .round
        pointLayer.strokeStart = point / 100
        pointLayer.strokeEnd = point / 100 + 0.00001
        
        progressView.layer.addSublayer(placeholderLayer)
        progressView.layer.addSublayer(progressLayer)
        progressView.layer.addSublayer(pointLayer)
    }
    
    @IBAction private func retakeQuizClicked(_ sender: Any) {
        delegate?.resultHeaderViewRetakeQuiz(self)
    }
    
    @IBAction private func allPageClicked(_ sender: Any) {
        allPageButton.isActive = true
        incorrectPageButton.isActive = false
        correctPageButton.isActive = false
        delegate?.resultHeaderViewAllPage(self)
    }
    
    @IBAction private func incorrectPageClicked(_ sender: Any) {
        allPageButton.isActive = false
        incorrectPageButton.isActive = true
        correctPageButton.isActive = false
        delegate?.resultHeaderViewIncorrectPage(self)
    }
    
    @IBAction private func correctPageClicked(_ sender: Any) {
        allPageButton.isActive = false
        incorrectPageButton.isActive = false
        correctPageButton.isActive = true
        delegate?.resultHeaderViewCorrectPage(self)
    }
    
}
