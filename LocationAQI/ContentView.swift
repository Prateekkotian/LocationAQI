//import SwiftUI
//
//@main
//struct DemoAppApp: App {
//    @State private var container: DIContainer
//    @State private var mapViewModel: MapViewModel
//    @State private var coordinator: AppCoordinator
//
//    init() {
//        let container = DIContainer()
//        let mapVM = MapViewModel(
//            network: container.networkManager,
//            cacheManager: container.cacheManager
//        )
//        _container = State(initialValue: container)
//        _mapViewModel = State(initialValue: mapVM)
//        _coordinator = State(initialValue: AppCoordinator(mapViewModel: mapVM))
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationStack(path: $coordinator.path) {
//                MapView()
//                    .navigationDestination(for: AppRoute.self) { route in
//                        destinationView(for: route)
//                    }
//            }
//            .environment(container)
//            .environment(coordinator)
//            .environment(mapViewModel)
//        }
//    }
//
//    @ViewBuilder
//    private func destinationView(for route: AppRoute) -> some View {
//        switch route {
//        case let .locationDetail(location, slot):
//            LocationDetailView(location: location, slot: slot)
//        case let .bookingConfirmation(record):
//            BookingConfirmationView(record: record)
//        case .history:
//            HistoryView()
//        case let .cacheList(slot):
//            CacheListView(slot: slot)
//        }
//    }
//}
//
