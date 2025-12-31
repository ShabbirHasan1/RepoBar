import RepoBarCore
import SwiftUI

struct RepoDetailView: View {
    @Bindable var appModel: AppModel
    let repository: Repository
    @State private var model: RepoDetailModel
    @Environment(\.openURL) private var openURL

    init(appModel: AppModel, repository: Repository) {
        self.appModel = appModel
        self.repository = repository
        _model = State(initialValue: RepoDetailModel(repo: repository, github: appModel.github))
    }

    var body: some View {
        List {
            Section {
                overview
            }

            if model.isLoading {
                Section {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity)
                }
            }

            if let error = model.error {
                Section {
                    Text(error).foregroundStyle(.orange)
                }
            }

            Section("Recent Activity") {
                if repository.activityEvents.isEmpty {
                    Text("No recent activity")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(repository.activityEvents.prefix(AppLimits.RepoActivity.limit), id: \.url) { event in
                        LinkRow(title: event.title, subtitle: event.actor, date: event.date, url: event.url)
                    }
                }
            }

            Section("Pull Requests") {
                if model.pulls.isEmpty {
                    Text("No open pull requests")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.pulls, id: \.url) { pr in
                        LinkRow(title: "#\(pr.number) \(pr.title)", subtitle: pr.authorLogin, date: pr.updatedAt, url: pr.url)
                    }
                }
            }

            Section("Issues") {
                if model.issues.isEmpty {
                    Text("No open issues")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.issues, id: \.url) { issue in
                        LinkRow(title: "#\(issue.number) \(issue.title)", subtitle: issue.authorLogin, date: issue.updatedAt, url: issue.url)
                    }
                }
            }

            Section("Releases") {
                if model.releases.isEmpty {
                    Text("No releases")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.releases, id: \.url) { release in
                        LinkRow(title: release.name, subtitle: release.tag, date: release.publishedAt, url: release.url)
                    }
                }
            }

            Section("Workflow Runs") {
                if model.workflows.isEmpty {
                    Text("No workflow runs")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.workflows, id: \.url) { run in
                        LinkRow(title: run.name, subtitle: run.branch ?? "", date: run.updatedAt, url: run.url)
                    }
                }
            }

            Section("Commits") {
                let commits = model.commits?.items ?? []
                if commits.isEmpty {
                    Text("No recent commits")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(commits, id: \.url) { commit in
                        LinkRow(title: commit.message, subtitle: commit.authorLogin, date: commit.authoredAt, url: commit.url)
                    }
                }
            }

            Section("Discussions") {
                if model.discussions.isEmpty {
                    Text("No discussions")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.discussions, id: \.url) { discussion in
                        LinkRow(title: discussion.title, subtitle: discussion.authorLogin, date: discussion.updatedAt, url: discussion.url)
                    }
                }
            }

            Section("Tags") {
                if model.tags.isEmpty {
                    Text("No tags")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.tags, id: \.name) { tag in
                        LinkRow(title: tag.name, subtitle: tag.commitSHA, date: nil, url: tagURL(tag.name))
                    }
                }
            }

            Section("Branches") {
                if model.branches.isEmpty {
                    Text("No branches")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.branches, id: \.name) { branch in
                        LinkRow(title: branch.name, subtitle: branch.commitSHA, date: nil, url: branchURL(branch.name))
                    }
                }
            }

            Section("Contributors") {
                if model.contributors.isEmpty {
                    Text("No contributors")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.contributors, id: \.login) { contributor in
                        LinkRow(title: contributor.login, subtitle: "\(contributor.contributions) contributions", date: nil, url: contributor.url)
                    }
                }
            }

            Section("Files") {
                NavigationLink {
                    RepoFilesView(appModel: appModel, repository: repository)
                } label: {
                    Label("Browse repository files", systemImage: "folder")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GlassBackground())
        .navigationTitle(repository.fullName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    openURL(repoURL())
                } label: {
                    Image(systemName: "arrow.up.right.square")
                }
            }
        }
        .task { await model.load() }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(repository.fullName)
                    .font(.headline)
                Spacer()
            }
            HStack(spacing: 10) {
                MetricPill(label: "CI", value: repository.ciStatus.label)
                MetricPill(label: "Issues", value: "\(repository.stats.openIssues)")
                MetricPill(label: "PRs", value: "\(repository.stats.openPulls)")
                MetricPill(label: "Stars", value: "\(repository.stats.stars)")
                MetricPill(label: "Forks", value: "\(repository.stats.forks)")
            }
            if let traffic = repository.traffic {
                Text("Visitors \(traffic.uniqueVisitors) • Cloners \(traffic.uniqueCloners)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let release = repository.latestRelease {
                Text("Latest release: \(release.name) — \(ReleaseFormatter.menuLine(for: release, now: Date()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private func repoURL() -> URL {
        RepoWebURLBuilder(host: appModel.session.settings.githubHost)
            .repoURL(fullName: repository.fullName) ?? appModel.session.settings.githubHost
    }

    private func tagURL(_ tag: String) -> URL {
        RepoWebURLBuilder(host: appModel.session.settings.githubHost)
            .tagURL(fullName: repository.fullName, tag: tag) ?? repoURL()
    }

    private func branchURL(_ branch: String) -> URL {
        RepoWebURLBuilder(host: appModel.session.settings.githubHost)
            .branchURL(fullName: repository.fullName, branch: branch) ?? repoURL()
    }
}

private struct MetricPill: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
            Text(value)
                .font(.caption2).bold()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct LinkRow: View {
    let title: String
    let subtitle: String?
    let date: Date?
    let url: URL?
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url { openURL(url) }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let date {
                        Text(RelativeFormatter.string(from: date, relativeTo: Date()))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private extension CIStatus {
    var label: String {
        switch self {
        case .passing: "Passing"
        case .failing: "Failing"
        case .pending: "Pending"
        case .unknown: "Unknown"
        }
    }
}
