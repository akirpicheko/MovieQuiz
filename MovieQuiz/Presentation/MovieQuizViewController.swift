import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol,
                                     AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
    }
    
    // MARK: - IB Actions
    @IBAction public func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction public func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Public Methods
    
    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func show(quiz result: QuizResultsViewModel){
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "GameResults"
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
            self.presenter.restartGame()
            
        }
        alertPresenter?.showAlert(model: model)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
        }
        changeStateButton(isEnabled: false)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            UIView.animate(withDuration: 0.5) {
                self.imageView.layer.borderWidth = 0
            }
            presenter.showNextQuestionOrResults()
            self.changeStateButton(isEnabled: true)
        }
        
    }
    
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func highlightBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    func animateBorder() {
        UIView.animate(withDuration: 0.5) {
            self.imageView.layer.borderWidth = 0
        }
    }
    
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
}
