import Foundation

actor CachePersistence {
    private let bookKey = "book_history"
    private let locationKey = "location_cache"
    private let defaults = UserDefaults.standard

    func saveBooks(_ records: [BookRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: bookKey)
        }
    }

    func loadBooks() -> [BookRecord] {
        guard let data = defaults.data(forKey: bookKey),
              let decoded = try? JSONDecoder().decode([BookRecord].self, from: data)
        else { return [] }
        return decoded
    }

    func saveLocations(_ stringKeyed: [String: LocationInfo]) {
        if let data = try? JSONEncoder().encode(stringKeyed) {
            defaults.set(data, forKey: locationKey)
        }
    }

    func loadLocations() -> [String: LocationInfo] {
        guard let data = defaults.data(forKey: locationKey),
              let decoded = try? JSONDecoder().decode([String: LocationInfo].self, from: data)
        else { return [:] }
        return decoded
    }
}
