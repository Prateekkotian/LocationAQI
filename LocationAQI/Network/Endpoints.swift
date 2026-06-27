import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}

enum Endpoint: Sendable {
    case airQuality(lat: Double, lng: Double, token: String)
    case reverseGeocode(lat: Double, lng: Double)
    case createBooking(body: BookRequestDTO)
    case fetchHistory(year: Int, month: Int)

    nonisolated var urlString: String {
        switch self {
        case let .airQuality(lat, lng, token):
            return "https://api.waqi.info/feed/geo:\(lat);\(lng)/?token=\(token)"
        case let .reverseGeocode(lat, lng):
            return "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=\(lat)&longitude=\(lng)&localityLanguage=en"
        case .createBooking:
            return "https://mock.example.com/books"
        case let .fetchHistory(year, month):
            return "https://mock.example.com/books?year=\(year)&month=\(month)"
        }
    }

    nonisolated var method: HTTPMethod {
        switch self {
        case .createBooking: return .post
        default: return .get
        }
    }

    nonisolated var body: Data? {
        switch self {
        case let .createBooking(body): return try? JSONEncoder().encode(body)
        default: return nil
        }
    }
}
