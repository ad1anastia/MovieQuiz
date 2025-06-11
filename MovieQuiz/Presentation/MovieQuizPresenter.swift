import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private weak var viewController: MovieQuizViewController?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
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
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IBAction methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
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
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    // MARK: - Private methods
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            // Обновляем статистику
            statisticService.store(correct: correctAnswers, total: 10)
            
            // Получаем текущие статистические данные
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            
            // Формируем строку результата
            let resultText = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
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
    
    private func proceedWithAnswer(isCorrect: Bool) {
      didAnswer(isCorrectAnswer: isCorrect)
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            //скрываем подсветку рамки
            viewController?.hideImageBorder()
            proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if (isCorrectAnswer) { correctAnswers += 1 }
        
    }
}
