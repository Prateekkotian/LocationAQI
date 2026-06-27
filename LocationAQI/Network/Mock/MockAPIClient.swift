import Foundation

final class MockAPIClient: APIClientProtocol {
    private let cache: CacheUseCase

    init(cache:  CacheUseCase) {
        self.cache = cache
    }

    nonisolated func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        print("→ [MOCK] \(endpoint.method.rawValue) \(endpoint.urlString)")

        try await Task.sleep(for: .milliseconds(300))

        let data: Data

        switch endpoint {
        case .airQuality:
            let json = """
            {"status":"ok","data":{"aqi":42,"idx":1234,"attributions":[],"city":{"geo":[35.67,139.70],"name":"Tokyo","url":""},"dominentpol":"pm25","iaqi":{},"time":{"s":"2026-06-25 12:00:00","tz":"+09:00","v":1750852800},"forecast":{"daily":{}},"debug":{}}}
            """
            data = Data(json.utf8)

        case .reverseGeocode:
            let json = """
            {"localityInfo":{"administrative":[{"name":"Japan","description":"country","isoName":"JP","order":1,"adminLevel":2,"isoCode":"JP","wikidataId":"Q17","geonameId":1861060},{"name":"Tokyo","description":"prefecture","isoName":"Tokyo","order":2,"adminLevel":4,"isoCode":"13","wikidataId":"Q1490","geonameId":1850147}]}}
            """
            data = Data(json.utf8)

        case let .createBooking(body):
            let encoded = (try? JSONEncoder().encode(body)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
            let echoBase = encoded.dropLast()
            let newId = UUID().uuidString
            let createdAt = ISO8601DateFormatter().string(from: Date())
            let json = "\(echoBase),\"price\":10000.0,\"id\":\"\(newId)\",\"createdAt\":\"\(createdAt)\"}"
            data = Data(json.utf8)

        case let .fetchHistory(year, month):
            let records = await MainActor.run { cache.resolved() }
            let cal = Calendar.current
            let filtered = records.filter {
                let c = cal.dateComponents([.year, .month], from: $0.createdAt)
                return c.year == year && c.month == month
            }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let dtos = filtered.compactMap { record -> BookResponseDTO? in
                guard let a = record.locationA, let b = record.locationB else { return nil }
                return BookResponseDTO(
                    id: record.id.uuidString,
                    a: .init(latitude: a.latitude, longitude: a.longitude, aqi: a.aqi, name: a.name),
                    b: .init(latitude: b.latitude, longitude: b.longitude, aqi: b.aqi, name: b.name),
                    price: record.price,
                    createdAt: record.createdAt
                )
            }
            data = (try? encoder.encode(dtos)) ?? Data("[]".utf8)
        }

        do {
            print("← [MOCK] 200 \(endpoint.urlString)")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("← [MOCK] decode error \(endpoint.urlString) — \(error.localizedDescription)")
            throw AppError.decodingError(error.localizedDescription)
        }
    }
}
