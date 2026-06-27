import MapKit
import CoreLocation
import Observation

enum BookingStep {
    case setA, setB, book

    var buttonTitle: String {
        switch self {
        case .setA: return "Set A"
        case .setB: return "Set B"
        case .book: return "Book"
        }
    }
}

@MainActor
@Observable
final class MapViewModel {
    // Store as primitive types so @Observable macro expansion doesn't need MapKit
    var centerLatitude: Double = 35.6762
    var centerLongitude: Double = 139.6503
    var latitudeDelta: Double = 0.05
    var longitudeDelta: Double = 0.05

    var centerAQI: Int? = nil
    var isLoadingAQI: Bool = false
    var locationA: LocationInfo? = nil
    var locationB: LocationInfo? = nil
    var bookingStep: BookingStep = .setA
    var isLoadingLocation: Bool = false
    var errorMessage: String? = nil

    var currentCenter: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }

    var coordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: currentCenter,
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }

    var navigationIntent: AppRoute? = nil

    private let network: NetworkUseCases
    private let cacheManager: CacheUseCase

    private var debounceTask: Task<Void, Never>?

    init(
        network: any NetworkUseCases,
        cacheManager: CacheUseCase
    ) {
        self.network = network
        self.cacheManager = cacheManager
    }

    func onCameraChanged(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        centerLatitude = center.latitude
        centerLongitude = center.longitude
        latitudeDelta = span.latitudeDelta
        longitudeDelta = span.longitudeDelta

        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }
            await self.updateAQI(for: center)
        }
    }

    func refreshAQI() async {
        await updateAQI(for: currentCenter)
    }

    private func updateAQI(for coord: CLLocationCoordinate2D) async {
        let lat = coord.latitude
        let lng = coord.longitude
        if let cached = cacheManager.getLocation(latitude: lat, longitude: lng) {
            centerAQI = cached.aqi
            return
        }
        isLoadingAQI = true
        centerAQI = nil
        do {
            centerAQI = try await network.fetchAQI(latitude: lat, longitude: lng)
        } catch {
            centerAQI = -1
        }
        isLoadingAQI = false
    }

    func onVButtonTapped() {
        let coord = currentCenter
        switch bookingStep {
        case .setA:
            Task { await setLocation(coord: coord, slot: .a) }
        case .setB:
            Task { await setLocation(coord: coord, slot: .b) }
        case .book:
            guard let a = locationA, let b = locationB else { return }
            Task { await createBooking(locationA: a, locationB: b) }
        }
    }

    private func createBooking(locationA: LocationInfo, locationB: LocationInfo) async {
        isLoadingLocation = true
        errorMessage = nil
        do {
            let record = try await network.createBooking(locationA: locationA, locationB: locationB)
            cacheManager.setLocation(locationA)
            cacheManager.setLocation(locationB)
            cacheManager.addBook(record)
            navigationIntent = .bookingConfirmation(record: record)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingLocation = false
    }

    private func setLocation(coord: CLLocationCoordinate2D, slot: LocationSlot) async {
        isLoadingLocation = true
        errorMessage = nil
        let lat = coord.latitude
        let lng = coord.longitude

        if let cached = cacheManager.getLocation(latitude: lat, longitude: lng) {
            applyLocation(cached, slot: slot)
            isLoadingLocation = false
            return
        }

        do {
            async let aqiResult = network.fetchAQI(latitude: lat, longitude: lng)
            async let nameResult = network.fetchLocationName(latitude: lat, longitude: lng)
            let (aqi, name) = try await (aqiResult, nameResult)
            let info = LocationInfo(latitude: lat, longitude: lng, name: name, aqi: aqi)
            cacheManager.setLocation(info)
            applyLocation(info, slot: slot)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingLocation = false
    }

    private func applyLocation(_ info: LocationInfo, slot: LocationSlot) {
        switch slot {
        case .a:
            locationA = info
            if bookingStep == .setA {
                if locationB != nil {
                    bookingStep = .book
                } else {
                    bookingStep = .setB
                }
            }
        case .b:
            locationB = info
            if bookingStep == .setB { bookingStep = .book }
        }
    }

    func onLabelTapped(slot: LocationSlot) {
        let location = slot == .a ? locationA : locationB
        if let loc = location {
            navigationIntent = .locationDetail(location: loc, slot: slot)
        } else {
            navigationIntent = .cacheList(slot: slot)
        }
    }

    func updateLocation(_ info: LocationInfo, slot: LocationSlot) {
        applyLocation(info, slot: slot)
        cacheManager.setLocation(info)
    }

    func preload(recordA: LocationInfo, recordB: LocationInfo) {
        locationA = recordA
        locationB = recordB
        bookingStep = .book
        Task { await updateAQI(for: CLLocationCoordinate2D(latitude: recordA.latitude, longitude: recordA.longitude)) }
        Task { await updateAQI(for: CLLocationCoordinate2D(latitude: recordB.latitude, longitude: recordB.longitude)) }
    }

    func resetState() {
        locationA = nil
        locationB = nil
        bookingStep = .setA
        centerAQI = nil
        errorMessage = nil
    }
}

