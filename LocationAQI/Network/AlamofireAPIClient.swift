import Alamofire
import Foundation

enum AppError: Error, LocalizedError, Sendable {
    case networkError(String)
    case decodingError(String)
    case aqiUnavailable
    case unknown

    nonisolated var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "Network error: \(msg)"
        case .decodingError(let msg): return "Decoding error: \(msg)"
        case .aqiUnavailable: return "AQI data is not available for this location"
        case .unknown: return "An unknown error occurred"
        }
    }
}

final class AlamofireAPIClient: APIClientProtocol {
    nonisolated func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: endpoint.urlString) else {
            throw AppError.networkError("Invalid URL: \(endpoint.urlString)")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        if let body = endpoint.body {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        print("→ \(endpoint.method.rawValue) \(url.absoluteString)")


        let response = await AF.request(urlRequest)
            .serializingDecodable(T.self)
            .response

        switch response.result {
        case .success(let value):
            print("← \(response.response?.statusCode ?? 0) \(url.absoluteString)")
            return value
        case .failure(let error):
            if let underlyingError = error.underlyingError {
                print("← \(response.response?.statusCode ?? 0) \(url.absoluteString) — \(error.localizedDescription)")
                throw AppError.networkError(underlyingError.localizedDescription)
            }
            throw AppError.networkError(error.localizedDescription)
        }
    }
}
