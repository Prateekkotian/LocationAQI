import SwiftUI
import MapKit
import CoreLocation


struct MapView: View {
    @Environment(MapViewModel.self) private var viewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var locationProvider = LocationProvider()

    var body: some View {
        MapContentView(viewModel: viewModel, locationProvider: locationProvider)
            .onAppear {
                locationProvider.requestOnce()
                Task { await viewModel.refreshAQI() }
            }
            .onChange(of: viewModel.navigationIntent) { _, route in
                guard let route else { return }
                coordinator.navigate(to: route)
                viewModel.navigationIntent = nil
            }
            .navigationBarHidden(true)
    }
}

private struct MapContentView: View {
    let viewModel: MapViewModel
    let locationProvider: LocationProvider

    @State private var cameraPosition: MapCameraPosition

    init(viewModel: MapViewModel, locationProvider: LocationProvider) {
        self.viewModel = viewModel
        self.locationProvider = locationProvider
        _cameraPosition = State(initialValue: .region(viewModel.coordinateRegion))
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .ignoresSafeArea()
                .onMapCameraChange(frequency: .continuous) { context in
                    viewModel.onCameraChanged(
                        center: context.region.center,
                        span: context.region.span
                    )
                }
                .onChange(of: locationProvider.userLocation) { _, coord in
                    guard let coord else { return }
                    withAnimation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
                .mapControls {
                }

            // Center pin
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)
                    .shadow(radius: 4)
            }
            .allowsHitTesting(false)

            // Top-right AQI badge
            VStack {
                HStack {
                    Spacer()
                    AQIBadgeView(aqi: viewModel.centerAQI, isLoading: viewModel.isLoadingAQI)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                }
                Spacer()
            }

            // Bottom bar
            VStack {
                Spacer()
                BottomBarView(viewModel: viewModel)
            }
        }
        .overlay {
            if viewModel.isLoadingLocation {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct AQIBadgeView: View {
    let aqi: Int?
    let isLoading: Bool

    var aqiColor: Color {
        guard let aqi, aqi != -1 else { return .gray }
        switch aqi {
        case ..<51: return .green
        case 51..<101: return .yellow
        case 101..<151: return .orange
        case 151..<201: return .red
        default: return .purple
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("AQI")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.7)
                } else if let aqi {
                    Text(aqi == -1 ? "-" : "\(aqi)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 36, height: 28)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(aqiColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}

private struct BottomBarView: View {
    let viewModel: MapViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 12) {
                LocationLabelButton(
                    label: "A",
                    location: viewModel.locationA
                ) {
                    viewModel.onLabelTapped(slot: .a)
                }

                LocationLabelButton(
                    label: "B",
                    location: viewModel.locationB
                ) {
                    viewModel.onLabelTapped(slot: .b)
                }
            }

            Button(action: { viewModel.onVButtonTapped() }) {
                Text(viewModel.bookingStep.buttonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 100)
            .frame(maxHeight: .infinity)
            .disabled(viewModel.isLoadingLocation)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .padding(.top, 16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct LocationLabelButton: View {
    let label: String
    let location: LocationInfo?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(.blue)
                    .clipShape(Circle())

                Text(location?.displayName ?? "")
                    .font(.subheadline)
                    .foregroundStyle(location == nil ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                if let aqi = location?.aqi, aqi != -1 {
                    Text("AQI \(aqi)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }

    private let cornerRadius: CGFloat = 10
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
