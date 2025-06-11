//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nastya Adodina on 11.06.2025.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol? = StatisticService()
    
    func isLastQuestion() -> Bool {
           currentQuestionIndex == questionsAmount - 1
       }
       
       func resetQuestionIndex() {
           currentQuestionIndex = 0
       }
       
       func switchToNextQuestion() {
           currentQuestionIndex += 1
       }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)" 
        )
    }
    
    func checkAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        // блокируем кнопки
        viewController?.setButtonsEnabled(false)
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
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
            // Обновляем статистику
            statisticService?.store(correct: correctAnswers, total: 10)
            
            // Получаем текущие статистические данные
            let gamesCount = statisticService?.gamesCount ?? 0
            let bestGame = statisticService?.bestGame
            let totalAccuracy = statisticService?.totalAccuracy ?? 0
            
            // Формируем строку результата
            let resultText = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame?.correct ?? 0)/\(bestGame?.total ?? 0) (\(bestGame?.date.dateTimeString ?? ""))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            
            // Создаем ViewModel для результатов
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultText,
                buttonText: "Сыграть ещё раз")
            viewController?.show(with: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
