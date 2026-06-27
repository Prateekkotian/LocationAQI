struct GeocodingResponseDTO: Decodable, Sendable {
    let city: String?
    let locality: String?
    let localityInfo: LocalityInfo

    struct LocalityInfo: Decodable, Sendable {
        let administrative: [AdminItem]
    }

    struct AdminItem: Decodable, Sendable {
        let name: String
        let order: Int
    }
}
