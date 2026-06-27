import Foundation

struct LocationInfo: Equatable, Identifiable, Hashable, Codable {
    let latitude: Double
    let longitude: Double
    let name: String
    let aqi: Int
    var nickname: String?

    var id: String { "\(cacheRound(latitude))_\(cacheRound(longitude))" }

    var displayName: String { nickname ?? name }

    private func cacheRound(_ value: Double) -> Double {
        floor(value * 1000) / 1000
    }
}
