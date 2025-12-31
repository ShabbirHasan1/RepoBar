import RepoBarCore
import SwiftUI

struct ActivityView: View {
    @Bindable var appModel: AppModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            if let error = appModel.session.globalActivityError {
                Section {
                    Text(error).foregroundStyle(.orange)
                }
            }

            Section("Activity") {
                if appModel.session.globalActivityEvents.isEmpty {
                    Text("No activity yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(appModel.session.globalActivityEvents, id: \.url) { event in
                        Button {
                            openURL(event.url)
                        } label: {
                            ActivityRow(event: event)
                        }
                    }
                }
            }

            Section("Commits") {
                if let error = appModel.session.globalCommitError {
                    Text(error).foregroundStyle(.orange)
                } else if appModel.session.globalCommitEvents.isEmpty {
                    Text("No commits yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(appModel.session.globalCommitEvents, id: \.url) { commit in
                        Button {
                            openURL(commit.url)
                        } label: {
                            CommitRow(commit: commit)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GlassBackground())
        .navigationTitle("Activity")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.requestRefresh(cancelInFlight: true)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

private struct ActivityRow: View {
    let event: ActivityEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ActivityIcon(symbolName: self.symbolName)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Text(event.actor)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(RelativeFormatter.string(from: event.date, relativeTo: Date()))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var symbolName: String {
        guard let type = event.eventTypeEnum else { return "clock" }
        switch type {
        case .pullRequest: return "arrow.triangle.branch"
        case .pullRequestReview: return "checkmark.bubble"
        case .pullRequestReviewComment: return "text.bubble"
        case .pullRequestReviewThread: return "text.bubble"
        case .issueComment: return "text.bubble"
        case .issues: return "exclamationmark.circle"
        case .push: return "arrow.up.circle"
        case .release: return "tag"
        case .watch: return "star"
        case .fork: return "doc.on.doc"
        case .create: return "plus"
        case .delete: return "trash"
        case .member: return "person.badge.plus"
        case .public: return "globe"
        case .gollum: return "book"
        case .commitComment: return "text.bubble"
        case .discussion: return "bubble.left.and.bubble.right"
        case .sponsorship: return "heart"
        }
    }
}

private struct CommitRow: View {
    let commit: RepoCommitSummary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ActivityIcon(symbolName: "arrow.turn.down.right")
            VStack(alignment: .leading, spacing: 4) {
                Text(commit.message)
                    .font(.subheadline)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    if let repo = commit.repoFullName {
                        Text(repo)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(RelativeFormatter.string(from: commit.authoredAt, relativeTo: Date()))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct ActivityIcon: View {
    let symbolName: String

    var body: some View {
        Image(systemName: symbolName)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            )
    }
}
