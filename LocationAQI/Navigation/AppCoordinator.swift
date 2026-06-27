import SwiftUI
import Observation

enum LocationSlot: Hashable {
    case a, b
}

enum AppRoute: Hashable {
    case locationDetail(location: LocationInfo, slot: LocationSlot)
    case bookingConfirmation(record: BookRecord)
    case history
    case cacheList(slot: LocationSlot)
}

@MainActor
@Observable
final class AppCoordinator {
    var path = NavigationPath()
    private let mapViewModel: MapViewModel

    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
    }/var/folders/6l/qycknszx39ggq_mh5gkq_z1m0000gn/T/TemporaryItems/NSIRD_screencaptureui_sTlSb8/Screen Recording 2026-06-27 at 8.59.11 PM.mov

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func goBackFromBooking() {
        popToRoot()
        mapViewModel.resetState()
    }
}

