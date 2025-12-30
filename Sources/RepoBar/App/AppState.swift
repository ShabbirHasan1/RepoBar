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
    private let settingsStore = SettingsStore()
    private let localRepoManager = LocalRepoManager()
    private let menuRefreshInterval: TimeInterval = 30
    private var refreshTask: Task<Void, Never>?
    private var localProjectsTask: Task<Void, Never>?
    private var tokenRefreshTask: Task<Void, Never>?
    private var menuRefreshTask: Task<Void, Never>?
    private var refreshTaskToken = UUID()
    private let hydrateConcurrencyLimit = 4
    private var prefetchTask: Task<Void, Never>?
    private let tokenRefreshInterval: TimeInterval = 300
    private let menuRefreshDebounceInterval: TimeInterval = 1
    private var lastMenuRefreshRequest: Date?

    // Default GitHub App values for convenience login from the main window.
    private let defaultClientID = RepoBarAuthDefaults.clientID
    private let defaultClientSecret = RepoBarAuthDefaults.clientSecret
    private let defaultLoopbackPort = RepoBarAuthDefaults.loopbackPort
    private let defaultGitHubHost = RepoBarAuthDefaults.githubHost
    private let defaultAPIHost = RepoBarAuthDefaults.apiHost

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
