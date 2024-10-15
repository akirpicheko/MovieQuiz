//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nastya on 15.10.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    var currentQuestionIndex: Int = .zero
     var currentQuestion: QuizQuestion?
   weak var viewController: MovieQuizViewController?
     let questionsAmount: Int = 10
    var correctAnswers: Int = .zero
    var questionFactory: QuestionFactoryProtocol?
   let statisticService: StatisticServiceProtocol = StatisticService()
    
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }

    func yesButtonClicked() {
            didAnswer(isYes: true)
        }
        
        func noButtonClicked() {
            didAnswer(isYes: false)
        }
    
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
        
        func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
        }
        
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
                let viewModel = convert(model: question)
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.show(quiz: viewModel)
                }
    }
    
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
     func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func restartGame() {
         currentQuestionIndex = 0
         correctAnswers = 0
         questionFactory?.requestNextQuestion()
     }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
func showNextQuestionOrResults() {
            if self.isLastQuestion() {
                statisticService.store(GameResult(correct: self.correctAnswers, total: self.questionsAmount, date: Date()))
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: (self.correctAnswers == self.questionsAmount ?
                           "Поздравляем, результат: \(self.questionsAmount) из \(self.questionsAmount)!\n" :
                            "Ваш результат: \(self.correctAnswers) из \(self.questionsAmount)\n") +
                                                                                  """
                                                                                  Колличество сыграных квизов: \(statisticService.gamesCount)
                                                                                  Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                                                                  Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                                                                  """,
                    buttonText: "Сыграть еще раз")
                viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
    
            }
        }
    
        func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    func makeResultsMessage() -> String {
            //statisticService.store(correct: correctAnswers, total: questionsAmount)
        statisticService.store(GameResult(correct: self.correctAnswers, total: self.questionsAmount, date: Date()))
            let bestGame = statisticService.bestGame
            
            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")
            
            return resultMessage
        }

}

