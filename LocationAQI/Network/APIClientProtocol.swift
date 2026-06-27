protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
}
