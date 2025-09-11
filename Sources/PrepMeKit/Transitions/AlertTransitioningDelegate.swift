import UIKit

class AlertTransitioningDelegate: NSObject {
    
    private var isPresenting = true
    
}

extension AlertTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AlertPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension AlertTransitioningDelegate: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: .from),
            let toController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        let toControllerFinalFrame = transitionContext.finalFrame(for: toController)
        
        if isPresenting {
            toController.view.clipsToBounds = true
            toController.view.layer.cornerRadius = 16
            toController.view.frame = toControllerFinalFrame
            toController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            toController.view.transform = .init(translationX: 0, y: 10)
            toController.view.alpha = 0
            transitionContext.containerView.addSubview(toController.view)
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        let curve = UIView.AnimationCurve(rawValue: 7) ?? .easeInOut
        if isPresenting {
            let animator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: {
                toController.view.transform = .identity
                toController.view.alpha = 1
            })
            animator.addCompletion { _ in
                transitionContext.completeTransition(true)
            }
            animator.startAnimation()
        } else {
            let animator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: {
                fromController.view.transform = .init(translationX: 0, y: 10)
                fromController.view.alpha = 0
            })
            animator.addCompletion { _ in
                fromController.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            animator.startAnimation()
        }
    }
    
}

class AlertPresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let horizontalPadding: CGFloat = 26
        let width = UIScreen.main.bounds.width - horizontalPadding * 2
        let height = (presentedView?.systemLayoutSizeFitting(CGSize(width: width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height ?? 500)
        return CGRect(
            x: horizontalPadding,
            y: (UIScreen.main.bounds.height - height) / 2,
            width: width,
            height: height
        )
    }
    
    private let dimmingView: UIView
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        dimmingView = UIView()
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dimmingView.alpha = 0
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        dimmingView.frame = containerView?.bounds ?? .zero
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { context in
                self.dimmingView.alpha = 1
            }, completion: nil)
        } else {
            self.dimmingView.alpha = 1
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { context in
                self.dimmingView.alpha = 0
            }, completion: nil)
        } else {
            dimmingView.alpha = 0
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
}
