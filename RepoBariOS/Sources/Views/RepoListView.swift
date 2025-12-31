import RepoBarCore
import SwiftUI

struct RepoListView: View {
    @Bindable var appModel: AppModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showAddRepo = false

    private var isGridLayout: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let error = appModel.session.lastError {
                    GlassCard {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.subheadline)
                        }
                    }
                }

                if appModel.session.settings.appearance.showContributionHeader,
                   !appModel.session.contributionHeatmap.isEmpty {
                    ContributionHeaderView(
                        heatmap: appModel.session.contributionHeatmap,
                        range: appModel.session.heatmapRange,
                        accentTone: appModel.session.settings.appearance.accentTone
                    )
                }

                if isGridLayout {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(appModel.session.repositories.map { RepositoryCardModel(repo: $0) }) { model in
                            NavigationLink {
                                RepoDetailView(appModel: appModel, repository: model.source)
                            } label: {
                                RepoCardView(appModel: appModel, model: model)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(appModel.session.repositories.map { RepositoryCardModel(repo: $0) }) { model in
                            NavigationLink {
                                RepoDetailView(appModel: appModel, repository: model.source)
                            } label: {
                                RepoCardView(appModel: appModel, model: model)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Repos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddRepo = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.requestRefresh(cancelInFlight: true)
                } label: {
                    if appModel.session.isRefreshing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddRepo) {
            NavigationStack {
                AddRepoSheet(appModel: appModel, isPresented: $showAddRepo)
            }
        }
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 280, maximum: 420), spacing: 16)]
    }
}

private struct ContributionHeaderView: View {
    let heatmap: [HeatmapCell]
    let range: HeatmapRange
    let accentTone: AccentTone

    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                HStack {
                    Text("Contribution Activity")
                        .font(.headline)
                    Spacer()
                }
                HeatmapView(cells: heatmap, accentTone: accentTone, height: 72)
                HeatmapAxisLabelsView(range: range, foregroundStyle: Color.secondary)
            }
        }
    }
}
