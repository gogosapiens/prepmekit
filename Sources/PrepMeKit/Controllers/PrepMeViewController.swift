import UIKit

class PrepMeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enforceLightInterfaceStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceLightInterfaceStyle()
    }
    
    private func enforceLightInterfaceStyle() {
        overrideUserInterfaceStyle = .light
        view.overrideUserInterfaceStyle = .light
    }
    
}
