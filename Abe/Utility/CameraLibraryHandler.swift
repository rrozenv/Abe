
import Foundation
import UIKit
import RxSwift

protocol PhotoLibraryImagePickedDelegate: class {
    var selectedImage: AnyObserver<UIImage> { get }
}

final class CameraHandler: NSObject {
    
    static let shared = CameraHandler()
    private override init() { }
    
    private weak var currentVC: UIViewController!
    private weak var delegate: PhotoLibraryImagePickedDelegate!
    
    func displayActionSheet(sourcVc: UIViewController,
                            imagePickedDelegate: PhotoLibraryImagePickedDelegate) {
        self.currentVC = sourcVc
        self.delegate = imagePickedDelegate
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] (alert:UIAlertAction!) -> Void in
                                                self?.display(.camera)
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery",
                                            style: .default,
                                            handler: { [weak self] (alert:UIAlertAction!) -> Void in
                                                self?.display(.photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sourcVc.present(actionSheet, animated: true, completion: nil)
    }
    
    private func display(_ sourceType:  UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = sourceType
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }

}

extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate.selectedImage.onNext(image)
        } else { print("Couldn't fetch image") }
        currentVC.dismiss(animated: true, completion: nil)
    }
    
}

