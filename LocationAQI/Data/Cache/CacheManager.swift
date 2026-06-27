import Foundation
import Observation

@MainActor
@Observable
final class CacheManager: CacheUseCase {
    private var store: [CacheKey: LocationInfo] = [:]
    private(set) var records: [BookRecord] = []
    private let persistence: CachePersistence

    private struct CacheKey: Hashable {
        let lat: Double
        let lng: Double
    }

    var all: [LocationInfo] {
        Array(store.values)
    }

    init(persistence: CachePersistence = CachePersistence()) {
        self.persistence = persistence
        Task { await load() }
    }

    func addBook(_ record: BookRecord) {
        records.append(record)
        let snapshot = records
        Task { await persistence.saveBooks(snapshot) }
    }

    func bookRecords(year: Int, month: Int) -> [BookRecord] {
        let cal = Calendar.current
        return records.filter {
            let c = cal.dateComponents([.year, .month], from: $0.createdAt)
            return c.year == year && c.month == month
        }
    }

    func resolved() -> [BookRecord] {
        records.map { record in
            var r = record
            r.locationA = getLocation(key: record.locationAKey)
            r.locationB = getLocation(key: record.locationBKey)
            return r
        }
    }

    func getLocation(latitude: Double, longitude: Double) -> LocationInfo? {
        store[makeKey(latitude, longitude)]
    }

    func getLocation(key: String) -> LocationInfo? {
        let parts = key.split(separator: "_").compactMap { Double($0) }
        guard parts.count == 2 else { return nil }
        return store[makeKey(parts[0], parts[1])]
    }

    func setLocation(_ info: LocationInfo) {
        store[makeKey(info.latitude, info.longitude)] = info
        let stringKeyed = Dictionary(uniqueKeysWithValues: store.map { key, value in
            ("\(key.lat)_\(key.lng)", value)
        })
        Task { await persistence.saveLocations(stringKeyed) }
    }

    private func load() async {
        let books = await persistence.loadBooks()
        let locations = await persistence.loadLocations()
        records = books
        store = Dictionary(uniqueKeysWithValues: locations.compactMap { stringKey, info in
            let parts = stringKey.split(separator: "_").compactMap { Double($0) }
            guard parts.count == 2 else { return nil }
            return (CacheKey(lat: parts[0], lng: parts[1]), info)
        })
    }

    private func makeKey(_ lat: Double, _ lng: Double) -> CacheKey {
        CacheKey(
            lat: floor(lat * 1000) / 1000,
            lng: floor(lng * 1000) / 1000
        )
    }
}
