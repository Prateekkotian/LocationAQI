import SwiftUI

struct BookingConfirmationView: View {
    @Environment(AppCoordinator.self) private var coordinator

    let record: BookRecord

    @State private var viewModel: BookingConfirmationViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                BookingConfirmationContentView(viewModel: vm)
                    .onChange(of: vm.navigationIntent) { _, route in
                        guard let route else { return }
                        coordinator.navigate(to: route)
                        vm.navigationIntent = nil
                    }
                    .onChange(of: vm.shouldGoBack) { _, should in
                        guard should else { return }
                        coordinator.goBackFromBooking()
                    }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = BookingConfirmationViewModel(record: record)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel?.goBack() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
}

private struct BookingConfirmationContentView: View {
    let viewModel: BookingConfirmationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BookingRecordView(record: viewModel.record)

                Button(action: { viewModel.goToHistory() }) {
                    Text("View History")
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

private struct BookingRecordView: View {
    let record: BookRecord

    var body: some View {
        VStack(spacing: 16) {
            if let a = record.locationA { LocationSummaryCard(label: "A", location: a) }
            if let b = record.locationB { LocationSummaryCard(label: "B", location: b) }

            HStack {
                Text("Price")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text("¥\(Int(record.price))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct LocationSummaryCard: View {
    let label: String
    let location: LocationInfo

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.blue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(location.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(String(format: "%.4f, %.4f", location.latitude, location.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("AQI")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(location.aqi == -1 ? "N/A" : "\(location.aqi)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
