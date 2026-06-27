struct BookRequestDTO: Encodable, Sendable {
    let a: LocationPayload
    let b: LocationPayload

    struct LocationPayload: Encodable, Sendable {
        let latitude: Double
        let longitude: Double
        let aqi: Int
        let name: String
    }
}
