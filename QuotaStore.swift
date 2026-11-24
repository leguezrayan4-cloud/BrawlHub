import Foundation

// Compteur de messages IA par mois, stocké sur l'appareil
@MainActor
final class QuotaStore: ObservableObject {
    static let monthlyLimit = AppConfig.monthlyQuota

    @Published private(set) var used = 0

    private let usedKey = "chatUsed"
    private let monthKey = "chatMonth"

    init() {
        refreshMonth()
    }

    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    func refreshMonth() {
        if UserDefaults.standard.string(forKey: monthKey) != currentMonth {
            UserDefaults.standard.set(currentMonth, forKey: monthKey)
            UserDefaults.standard.set(0, forKey: usedKey)
        }
        used = UserDefaults.standard.integer(forKey: usedKey)
    }

    var remaining: Int {
        max(Self.monthlyLimit - used, 0)
    }

    var fractionUsed: Double {
        min(Double(used) / Double(Self.monthlyLimit), 1)
    }

    func registerMessage() {
        refreshMonth()
        used += 1
        UserDefaults.standard.set(used, forKey: usedKey)
    }
}
