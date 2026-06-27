import Foundation

struct BookResponseDTO: Codable, Sendable {
    let id: String?
    let a: LocationPayload
    let b: LocationPayload
    let price: Double
    let createdAt: Date?

    struct LocationPayload: Codable, Sendable {
        let latitude: Double
        let longitude: Double
        let aqi: Int
        let name: String
    }
}
