protocol NetworkUseCases: Sendable {
    func fetchAQI(latitude: Double, longitude: Double) async throws -> Int
    func createBooking(locationA: LocationInfo, locationB: LocationInfo) async throws -> BookRecord
    func fetchHistory(year: Int, month: Int) async throws -> [BookRecord]
    func fetchLocationName(latitude: Double, longitude: Double) async throws -> String
}
