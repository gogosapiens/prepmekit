import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(of cellClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as! T
    }
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: .module)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(of headerFooterViewClass: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: headerFooterViewClass)) as! T
    }
    
    func register<T: UITableViewHeaderFooterView>(_ headerFooterViewClass: T.Type) {
        let identifier = String(describing: headerFooterViewClass)
        let nib = UINib(nibName: identifier, bundle: .module)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
}
