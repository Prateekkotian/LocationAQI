import Foundation
import Observation

@MainActor
@Observable
final class DIContainer {
    let networkManager: any NetworkUseCases
    let cacheManager: CacheUseCase

    init() {
        cacheManager = CacheManager()
        let apiClient = AlamofireAPIClient()
        let mockClient = MockAPIClient(cache: cacheManager)
        networkManager = NetworkManager(
            apiClient: apiClient,
            mockAPIClient: mockClient,
        )
    }
}
