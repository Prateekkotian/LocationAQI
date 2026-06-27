struct AQIResponseDTO: Decodable, Sendable {
    let status: String
    let data: AQIData

    struct AQIData: Decodable, Sendable {
        let aqi: Int

        nonisolated init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let intVal = try? container.decode(Int.self, forKey: .aqi) {
                aqi = intVal
            } else {
                // AQICN returns "-" string when no data is available
                aqi = -1
            }
        }

        enum CodingKeys: String, CodingKey { case aqi }
    }
}
