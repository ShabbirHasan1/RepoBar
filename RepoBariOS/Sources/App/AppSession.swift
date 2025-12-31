import Foundation
import Observation
import RepoBarCore

@Observable
final class AppSession {
    var account: AccountState = .loggedOut
    var repositories: [Repository] = []
    var settings = UserSettings()
    var lastError: String?
    var isRefreshing = false
    var heatmapRange: HeatmapRange = HeatmapFilter.range(span: .twelveMonths, now: Date(), alignToWeek: true)
    var contributionHeatmap: [HeatmapCell] = []
    var contributionUser: String?
    var contributionError: String?
    var globalActivityEvents: [ActivityEvent] = []
    var globalActivityError: String?
    var globalCommitEvents: [RepoCommitSummary] = []
    var globalCommitError: String?
}

enum AccountState: Equatable {
    case loggedOut
    case loggingIn
    case loggedIn(UserIdentity)
}
