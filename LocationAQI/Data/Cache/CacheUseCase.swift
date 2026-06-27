import Foundation

@MainActor
protocol CacheUseCase: AnyObject {
    var records: [BookRecord] { get }
    func addBook(_ record: BookRecord)
    func resolved() -> [BookRecord]
    func getLocation(latitude: Double, longitude: Double) -> LocationInfo?
    func getLocation(key: String) -> LocationInfo?
    func setLocation(_ info: LocationInfo)
    var all: [LocationInfo] { get }
}

