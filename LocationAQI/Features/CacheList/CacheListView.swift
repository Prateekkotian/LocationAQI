import SwiftUI

struct CacheListView: View {
    @Environment(DIContainer.self) private var container
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(MapViewModel.self) private var mapViewModel

    let slot: LocationSlot

    @State private var viewModel: CacheListViewModel?

    var body: some View {
        CacheListContentView(viewModel: resolvedViewModel, slot: slot)
            .onChange(of: viewModel?.selectedLocation) { _, location in
                guard let location else { return }
                mapViewModel.updateLocation(location, slot: slot)
                coordinator.pop()
            }
            .navigationTitle("Select Location \(slot == .a ? "A" : "B")")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var resolvedViewModel: CacheListViewModel {
        if let vm = viewModel { return vm }
        let vm = CacheListViewModel(
            slot: slot,
            cacheManager: container.cacheManager
        )
        Task { @MainActor in viewModel = vm }
        return vm
    }
}

private struct CacheListContentView: View {
    @Bindable var viewModel: CacheListViewModel
    let slot: LocationSlot

    var body: some View {
        Group {
            if viewModel.cachedLocations.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "mappin.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No cached locations yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Set a location using the map to populate this list")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
            } else {
                List(viewModel.cachedLocations) { location in
                    CachedLocationRow(location: location)
                        .onTapGesture {
                            viewModel.select(location)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct CachedLocationRow: View {
    let location: LocationInfo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(location.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(String(format: "%.4f, %.4f", location.latitude, location.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("AQI")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(location.aqi == -1 ? "-" : "\(location.aqi)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

