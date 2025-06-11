import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    // MARK: Properties
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    
    
    @IBOutlet private weak var buttonYes: UIButton!
    @IBOutlet private weak var buttonNo: UIButton!
    
    private var correctAnswers = 0
    
    private var alertPresenter: AlertPresenter?
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        
        questionFactory?.loadData()
    }
    
    // MARK: - IBAction methods
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.checkAnswer(givenAnswer: true)
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.checkAnswer(givenAnswer: false)
    }
    
    // MARK: - Private methods
    
    // Общий метод для включения/выключения обеих кнопок
    func setButtonsEnabled(_ isEnabled: Bool) {
        buttonYes.isEnabled = isEnabled
        buttonNo.isEnabled = isEnabled
    }
    
    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
    
    //анимация появления картинок
           UIView.transition(with: imageView,
                             duration: 0.3,
                             options: .transitionCrossDissolve,
                             animations: {
               self.imageView.image = step.image
               self.textLabel.text = step.question
               self.counterLabel.text = step.questionNumber
           })
        
        // разблокировать кнопки
        setButtonsEnabled(true)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            //скрываем подсветку рамки
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(with result: QuizResultsViewModel) {
        let alertPresenter = AlertPresenter(viewController: self)
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
       alertPresenter.show(alert: alertModel)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertPresenter = AlertPresenter(viewController: self)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            self.setButtonsEnabled(true)
            
        }
        alertPresenter.show(alert: model)
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.isHidden = false
            self?.activityIndicator?.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Public Methods
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) 
    }
}
    
/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */

