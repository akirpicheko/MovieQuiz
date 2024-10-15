//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nastya on 16.10.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightBorder(isCorrect: Bool)
    func changeStateButton(isEnabled: Bool)
    func animateBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
} 
