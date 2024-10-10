import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case gamesCount
        case correct
        case total
        case date
        case correctAnswers
        case totalAnswers
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double{
        get {
            return gamesCount > 0 ? Double(100 * correctAnswers / totalAnswers) : 0
        }
    }
    
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    private var totalAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }
    
    func store(_ currentGameResult: GameResult) {
        correctAnswers += currentGameResult.correct
        totalAnswers += currentGameResult.total
        
        gamesCount += 1
        
        if currentGameResult.isBetterThan(bestGame){
            bestGame = currentGameResult
        }
    }
}

