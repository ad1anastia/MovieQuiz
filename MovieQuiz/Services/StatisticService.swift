import Foundation

final class StatisticService: StatisticServiceProtocol  {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }

    // Cчётчик сыгранных игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    // Рекордная игра
    var bestGame: GameResult {
        get {
            // Получаем сохранённые значения или задаём дефолтные
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            
            // Получаем дату, если есть, иначе текущая дата
            let dateObject = storage.object(forKey: Keys.bestGameDate.rawValue)
            let date = (dateObject as? Date) ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    // Cвойство для хранения общего количества правильных ответов
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }

    // Вычисление средней точности в процентах
    var totalAccuracy: Double {
        let questionsPerGame: Int = 10 // Не нравится, что приходится укаывать это число в нескольких местах
        guard gamesCount > 0 else { return 0.0 } // избегаем деления на ноль
        
        // Общее число вопросов — это количество игр умноженное на число вопросов в каждой игре
        let totalQuestions = questionsPerGame * gamesCount
        guard totalQuestions > 0 else { return 0.0 }
        
        // Расчет процента правильных ответов от общего числа вопросов
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }

    func store(correct count: Int, total amount: Int) {
        // Обновляем общее количество правильных ответов
        correctAnswers += count
        
        // Обновляем количество сыгранных игр
        gamesCount += 1
        
        let currentResult = GameResult(correct: count, total: amount, date: Date())
        if currentResult.isBetterThan(bestGame){
            bestGame = currentResult
        }
    }
}
