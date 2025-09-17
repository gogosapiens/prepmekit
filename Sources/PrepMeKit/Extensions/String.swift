import UIKit

extension String {
    func removingHTMLTags() -> String {
        let html = replacingOccurrences(of: "</p>", with: "</p><br>")
        if let data = html.data(using: .utf8) {
            do {
                return try NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                ).string.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                return self
            }
        }
        return self
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
}
