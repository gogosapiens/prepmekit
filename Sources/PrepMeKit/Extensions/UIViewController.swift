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
        
        present(viewControllerToPresent, height: fittingSize.height, animated: animated)
    }
    
    func present(
        _ viewControllerToPresent: UIViewController,
        height: CGFloat,
        animated: Bool = true
    ) {
        if let sheet = viewControllerToPresent.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in height }
                ]
            }
        }
        
        present(viewControllerToPresent, animated: animated)
    }
    
}
