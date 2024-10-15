import UIKit

final class MovieQuizViewController: UIViewController,
                                      AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
//    private var currentQuestionIndex: Int = .zero
    //private var correctAnswers: Int = .zero
//    private let questionsAmount: Int = 10
    //var questionFactory: QuestionFactoryProtocol?
    //private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    //private let presenter = MovieQuizPresenter()
    private var presenter: MovieQuizPresenter!

    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        //questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
        //presenter.viewController = self
        presenter = MovieQuizPresenter(viewController: self)

        imageView.layer.cornerRadius = 20
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {

//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let givenAnswer = true
//        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
          //presenter.currentQuestion = currentQuestion
          presenter.yesButtonClicked()
        
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        //presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let givenAnswer = false
//        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Public Methods
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        
//        presenter.didReceiveNextQuestion(question: question)
//    }
    
    
    
//        guard let question = question else {
//            return
//        }
//        
//        currentQuestion = question
//        let viewModel = presenter.convert(model: question)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.show(quiz: viewModel)
//        }
   

    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func show(quiz result: QuizResultsViewModel){
        let message = presenter.makeResultsMessage()
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.presenter.correctAnswers = 0
                self.presenter.resetQuestionIndex()
                   //  self.questionFactory?.requestNextQuestion()
            })
        
        
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
            
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
//        alertPresenter?.showAlert(model: alertModel)
    }
    
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
//    
//    func didLoadDataFromServer() {
//        activityIndicator.isHidden = true 
//        questionFactory?.requestNextQuestion()
//    }
    
    // MARK: - Private Methods
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        return QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//    }
    
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

            //self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: model)
    }
    
    // Перенести в public
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
    
     private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            statisticService.store(GameResult(correct: presenter.correctAnswers, total: presenter.questionsAmount, date: Date()))
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: (presenter.correctAnswers == presenter.questionsAmount ?
//                       "Поздравляем, результат: \(presenter.questionsAmount) из \(presenter.questionsAmount)!\n" :
//                        "Ваш результат: \(presenter.correctAnswers) из \(presenter.questionsAmount)\n") +
//                                                                              """
//                                                                              Колличество сыграных квизов: \(statisticService.gamesCount)
//                                                                              Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
//                                                                              Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
//                                                                              """,
//                buttonText: "Сыграть еще раз")
//            show(quiz: viewModel)
//        } else {
//            presenter.switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//            
//        }
//    }
}
