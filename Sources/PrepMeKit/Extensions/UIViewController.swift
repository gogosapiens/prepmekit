import UIKit

extension UIViewController {
    
    func presentAutoHeight(
        _ viewControllerToPresent: UIViewController,
        animated: Bool = true
    ) {
        viewControllerToPresent.loadViewIfNeeded()
        
        let fittingSize = viewControllerToPresent.view.systemLayoutSizeFitting(
            CGSize(width: UIScreen.main.bounds.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        if let sheet = viewControllerToPresent.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in fittingSize.height }
                ]
            }
        }
        
        present(viewControllerToPresent, animated: animated)
    }
    
}
