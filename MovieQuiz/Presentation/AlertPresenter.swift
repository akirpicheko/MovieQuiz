import UIKit

final class AlertPresenter {
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)  
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        delegate?.presentAlert(alert)
    }
}
