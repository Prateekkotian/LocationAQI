import SwiftUI

struct HistoryView: View {
    @Environment(DIContainer.self) private var container
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(MapViewModel.self) private var mapViewModel

    @State private var viewModel: HistoryViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                HistoryContentView(viewModel: vm)
                    .onChange(of: vm.selectedRecord) { _, record in
                        guard let a = record?.locationA, let b = record?.locationB else { return }
                        mapViewModel.preload(recordA: a, recordB: b)
                    }
                    .onChange(of: vm.shouldPopToRoot) { _, should in
                        guard should else { return }
                        coordinator.popToRoot()
                        vm.shouldPopToRoot = false
                    }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HistoryViewModel(network: container.networkManager)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HistoryContentView: View {
    @Bindable var viewModel: HistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            HStack(spacing: 0) {
                SummaryCard(title: "Total Trips", value: "\(viewModel.totalCount)")
                Divider().frame(height: 40)
                SummaryCard(title: "Total Spent", value: "¥\(Int(viewModel.totalPrice))")
            }
            .padding()
            .background(.regularMaterial)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.records.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No bookings this month")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                List(viewModel.records) { record in
                    BookRecordRow(record: record)
                        .onTapGesture {
                            viewModel.selectRecord(record)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.loadHistory()
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BookRecordRow: View {
    let record: BookRecord

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        LabelBadge(text: "A")
                        Text(record.locationA?.displayName ?? "")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    HStack(spacing: 8) {
                        LabelBadge(text: "B")
                        Text(record.locationB?.displayName ?? "")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Text("¥\(Int(record.price))")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct LabelBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: 18, height: 18)
            .background(.blue)
            .clipShape(Circle())
    }
}

