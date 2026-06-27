import Foundation
import Observation

@MainActor
@Observable
final class CacheListViewModel {
    let slot: LocationSlot
    var selectedLocation: LocationInfo? = nil
    private let cacheManager: CacheUseCase

    var cachedLocations: [LocationInfo] { cacheManager.all }

    init(slot: LocationSlot, cacheManager: CacheUseCase) {
        self.slot = slot
        self.cacheManager = cacheManager
    }

    func select(_ location: LocationInfo) {
        selectedLocation = location
    }
}

