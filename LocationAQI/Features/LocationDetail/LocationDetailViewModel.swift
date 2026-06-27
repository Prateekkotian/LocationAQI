import Foundation
import Observation

@MainActor
@Observable
final class LocationDetailViewModel {
    var nickname: String = ""
    var nicknameError: String? = nil

    let location: LocationInfo
    let slot: LocationSlot
    var confirmedLocation: LocationInfo? = nil

    private let cacheManager: CacheUseCase

    init(location: LocationInfo, slot: LocationSlot, cacheManager: CacheUseCase) {
        self.location = location
        self.slot = slot
        self.cacheManager = cacheManager
        self.nickname = location.nickname ?? ""
    }

    func confirm() {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard trimmed.count <= 20 else {
            nicknameError = "Nickname must be 20 characters or fewer"
            return
        }
        var updated = location
        updated.nickname = trimmed.isEmpty ? nil : trimmed
        cacheManager.setLocation(updated)
        confirmedLocation = updated
    }
}

