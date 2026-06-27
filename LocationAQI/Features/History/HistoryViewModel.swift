import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {
    var records: [BookRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var totalCount: Int { records.count }
    var totalPrice: Double { records.reduce(0) { $0 + $1.price } }

    var selectedRecord: BookRecord? = nil

    var shouldPopToRoot: Bool = false

    private let network: any NetworkUseCases

    init(network: any NetworkUseCases) {
        self.network = network
    }

    func loadHistory() async {
        isLoading = true
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        let year = components.year ?? 2026
        let month = components.month ?? 6
        do {
            records = try await network.fetchHistory(year: year, month: month)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func selectRecord(_ record: BookRecord) {
        guard record.locationA != nil, record.locationB != nil else { return }
        selectedRecord = record
        shouldPopToRoot = true
    }
}

