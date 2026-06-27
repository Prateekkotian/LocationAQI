import Foundation

final class NetworkManager: NetworkUseCases {
    private let apiClient: any APIClientProtocol
    private let mockAPIClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol, mockAPIClient: any APIClientProtocol) {
        self.apiClient = apiClient
        self.mockAPIClient = mockAPIClient
    }


    func fetchAQI(latitude: Double, longitude: Double) async throws -> Int {
        let dto: AQIResponseDTO = try await apiClient.request(
            endpoint: .airQuality(lat: latitude, lng: longitude, token: Config.aqiToken)
        )
        guard dto.status == "ok" else { throw AppError.aqiUnavailable }
        return dto.data.aqi
    }

    func fetchLocationName(latitude: Double, longitude: Double) async throws -> String {
        let dto: GeocodingResponseDTO = try await apiClient.request(
            endpoint: .reverseGeocode(lat: latitude, lng: longitude)
        )
        let sorted = dto.localityInfo.administrative.sorted { $0.order > $1.order }
        let names = sorted.prefix(2).map(\.name)
        return names.isEmpty ? "Unknown Location" : names.joined(separator: ", ")
    }

    func createBooking(locationA: LocationInfo, locationB: LocationInfo) async throws -> BookRecord {
        let body = BookRequestDTO(
            a: .init(latitude: locationA.latitude, longitude: locationA.longitude, aqi: locationA.aqi, name: locationA.name),
            b: .init(latitude: locationB.latitude, longitude: locationB.longitude, aqi: locationB.aqi, name: locationB.name)
        )
        let dto: BookResponseDTO = try await mockAPIClient.request(endpoint: .createBooking(body: body))
        return BookRecord(
            id: dto.id.flatMap(UUID.init) ?? UUID(),
            locationA: LocationInfo(latitude: dto.a.latitude, longitude: dto.a.longitude, name: dto.a.name, aqi: dto.a.aqi),
            locationB: LocationInfo(latitude: dto.b.latitude, longitude: dto.b.longitude, name: dto.b.name, aqi: dto.b.aqi),
            price: dto.price,
            createdAt: dto.createdAt ?? Date()
        )
    }

    func fetchHistory(year: Int, month: Int) async throws -> [BookRecord] {
        let dtos: [BookResponseDTO] = try await mockAPIClient.request(endpoint: .fetchHistory(year: year, month: month))
        return dtos.map { dto in
            BookRecord(
                id: dto.id.flatMap(UUID.init) ?? UUID(),
                locationA: LocationInfo(latitude: dto.a.latitude, longitude: dto.a.longitude, name: dto.a.name, aqi: dto.a.aqi),
                locationB: LocationInfo(latitude: dto.b.latitude, longitude: dto.b.longitude, name: dto.b.name, aqi: dto.b.aqi),
                price: dto.price,
                createdAt: dto.createdAt ?? Date()
            )
        }
    }
}
