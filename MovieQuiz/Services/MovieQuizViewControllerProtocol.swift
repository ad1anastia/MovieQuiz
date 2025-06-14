//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nastya Adodina on 11.06.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(with result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setButtonsEnabled(_ isEnabled: Bool)
    func hideImageBorder()
}
