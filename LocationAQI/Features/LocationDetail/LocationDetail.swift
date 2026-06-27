import SwiftUI

struct LocationDetailView: View {
    @Environment(DIContainer.self) private var container
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(MapViewModel.self) private var mapViewModel

    let location: LocationInfo
    let slot: LocationSlot

    @State private var viewModel: LocationDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                LocationDetailContentView(viewModel: vm)
                    .onChange(of: vm.confirmedLocation) { _, updated in
                        guard let updated else { return }
                        mapViewModel.updateLocation(updated, slot: slot)
                        coordinator.pop()
                    }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LocationDetailViewModel(
                    location: location,
                    slot: slot,
                    cacheManager: container.cacheManager
                )
            }
        }
        .navigationTitle("Location Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LocationDetailContentView: View {
    @Bindable var viewModel: LocationDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Location info card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text(viewModel.location.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        InfoItem(title: "Latitude", value: String(format: "%.4f", viewModel.location.latitude))
                        InfoItem(title: "Longitude", value: String(format: "%.4f", viewModel.location.longitude))
                    }

                    HStack {
                        Text("Air Quality Index")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        AQIValueText(aqi: viewModel.location.aqi)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Nickname section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nickname (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    TextField("Enter a nickname (max 20 chars)", text: $viewModel.nickname)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: viewModel.nickname) { _, newValue in
                            if newValue.count > 20 {
                                viewModel.nickname = String(newValue.prefix(20))
                            }
                            viewModel.nicknameError = nil
                        }

                    if let error = viewModel.nicknameError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Text("\(viewModel.nickname.count)/20")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button(action: { viewModel.confirm() }) {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }
}

private struct InfoItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

private struct AQIValueText: View {
    let aqi: Int

    var color: Color {
        switch aqi {
        case ..<51: return .green
        case 51..<101: return .yellow
        case 101..<151: return .orange
        case 151..<201: return .red
        default: return .purple
        }
    }

    var body: some View {
        Text(aqi == -1 ? "N/A" : "\(aqi)")
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(color)
    }
}

