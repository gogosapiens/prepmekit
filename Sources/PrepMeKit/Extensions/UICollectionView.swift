import UIKit

extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(
        of cellClass: T.Type,
        for indexPath: IndexPath
    ) -> T {
        dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as! T
    }
    
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: .module)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        of supplementaryViewClass: T.Type,
        kind: String,
        for indexPath: IndexPath
    ) -> T {
        dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: supplementaryViewClass), for: indexPath) as! T
    }
    
    func register<T: UICollectionReusableView>(
        _ supplementaryViewClass: T.Type,
        kind: String
    ) {
        let identifier = String(describing: supplementaryViewClass)
        register(UINib(nibName: identifier, bundle: .module), forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
}
