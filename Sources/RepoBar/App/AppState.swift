import Foundation
import Observation
import RepoBarCore

// MARK: - AppState container

@MainActor
@Observable
final class AppState {
    var session = Session()
    let auth = OAuthCoordinator()
    let github = GitHubClient()
    let refreshScheduler = RefreshScheduler()
    let settingsStore = SettingsStore()
    let localRepoManager = LocalRepoManager()
    let menuRefreshInterval: TimeInterval = 30
    var refreshTask: Task<Void, Never>?
    var localProjectsTask: Task<Void, Never>?
    private var tokenRefreshTask: Task<Void, Never>?
    var menuRefreshTask: Task<Void, Never>?
    var refreshTaskToken = UUID()
    let hydrateConcurrencyLimit = 4
    var prefetchTask: Task<Void, Never>?
    private let tokenRefreshInterval: TimeInterval = 300
    let menuRefreshDebounceInterval: TimeInterval = 1
    var lastMenuRefreshRequest: Date?

    // Default GitHub App values for convenience login from the main window.
    let defaultClientID = RepoBarAuthDefaults.clientID
    let defaultClientSecret = RepoBarAuthDefaults.clientSecret
    let defaultLoopbackPort = RepoBarAuthDefaults.loopbackPort
    let defaultGitHubHost = RepoBarAuthDefaults.githubHost
    let defaultAPIHost = RepoBarAuthDefaults.apiHost

    init() {
        self.session.settings = self.settingsStore.load()
        _ = self.auth.loadTokens()
        Task {
            await self.github.setTokenProvider { @Sendable [weak self] () async throws -> OAuthTokens? in
                try? await self?.auth.refreshIfNeeded()
            }
        }
        self.tokenRefreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                if self.auth.loadTokens() != nil {
                    _ = try? await self.auth.refreshIfNeeded()
                }
                try? await Task.sleep(for: .seconds(self.tokenRefreshInterval))
            }
        }
        self.refreshScheduler.configure(interval: self.session.settings.refreshInterval.seconds) { [weak self] in
            self?.requestRefresh()
        }
        Task { await DiagnosticsLogger.shared.setEnabled(self.session.settings.diagnosticsEnabled) }
    }

    struct GlobalActivityResult {
        let events: [ActivityEvent]
        let commits: [RepoCommitSummary]
        let error: String?
        let commitError: String?
    }

    func diagnostics() async -> DiagnosticsSummary {
        await self.github.diagnostics()
    }

    func clearCaches() async {
        await self.github.clearCache()
        ContributionCacheStore.clear()
    }

    func persistSettings() {
        self.settingsStore.save(self.session.settings)
    }
}
