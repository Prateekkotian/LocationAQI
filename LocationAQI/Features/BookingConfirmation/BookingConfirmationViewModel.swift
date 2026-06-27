import Foundation
import Observation

@MainActor
@Observable
final class BookingConfirmationViewModel {
    let record: BookRecord
    var navigationIntent: AppRoute? = nil
    var shouldGoBack: Bool = false

    init(record: BookRecord) {
        self.record = record
    }

    func goToHistory() {
        navigationIntent = .history
    }

    func goBack() {
        shouldGoBack = true
    }
}

