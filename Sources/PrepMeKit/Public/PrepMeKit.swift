import UIKit

@MainActor
final public class PrepMeKit {
    
    private init() {
        
    }
    
    public static func configure() {
        PrepMeKitInternal.shared.configure()
    }
    
    public static func getRootViewController() -> UIViewController {
        return PrepMeKitInternal.shared.getRootViewController()
    }
    
}
