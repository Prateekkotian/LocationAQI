import Foundation

struct BookRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let locationAKey: String   // "floor(lat*1000)/1000_floor(lng*1000)/1000"
    let locationBKey: String
    let price: Double
    let createdAt: Date

    // Resolved views — populated after lookup in LocationCache
    var locationA: LocationInfo?
    var locationB: LocationInfo?
}

extension BookRecord {
    init(id: UUID = UUID(), locationA: LocationInfo, locationB: LocationInfo, price: Double, createdAt: Date) {
        self.id = id
        self.locationAKey = locationA.id
        self.locationBKey = locationB.id
        self.price = price
        self.createdAt = createdAt
        self.locationA = locationA
        self.locationB = locationB
    }
}
