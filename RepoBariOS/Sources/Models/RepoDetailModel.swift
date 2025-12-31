import Foundation
import Observation
import RepoBarCore

@MainActor
@Observable
final class RepoDetailModel {
    let repo: Repository
    private let github: GitHubClient
    var isLoading = false
    var pulls: [RepoPullRequestSummary] = []
    var issues: [RepoIssueSummary] = []
    var releases: [RepoReleaseSummary] = []
    var workflows: [RepoWorkflowRunSummary] = []
    var commits: RepoCommitList?
    var discussions: [RepoDiscussionSummary] = []
    var tags: [RepoTagSummary] = []
    var branches: [RepoBranchSummary] = []
    var contributors: [RepoContributorSummary] = []
    var error: String?

    init(repo: Repository, github: GitHubClient) {
        self.repo = repo
        self.github = github
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        async let pullsResult: Result<[RepoPullRequestSummary], Error> = capture {
            try await github.recentPullRequests(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let issuesResult: Result<[RepoIssueSummary], Error> = capture {
            try await github.recentIssues(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let releasesResult: Result<[RepoReleaseSummary], Error> = capture {
            try await github.recentReleases(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let workflowsResult: Result<[RepoWorkflowRunSummary], Error> = capture {
            try await github.recentWorkflowRuns(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let commitsResult: Result<RepoCommitList, Error> = capture {
            try await github.recentCommits(owner: repo.owner, name: repo.name, limit: AppLimits.RepoCommits.totalLimit)
        }
        async let discussionsResult: Result<[RepoDiscussionSummary], Error> = capture {
            try await github.recentDiscussions(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let tagsResult: Result<[RepoTagSummary], Error> = capture {
            try await github.recentTags(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let branchesResult: Result<[RepoBranchSummary], Error> = capture {
            try await github.recentBranches(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }
        async let contributorsResult: Result<[RepoContributorSummary], Error> = capture {
            try await github.topContributors(owner: repo.owner, name: repo.name, limit: AppLimits.RecentLists.limit)
        }

        switch await pullsResult {
        case let .success(value): pulls = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await issuesResult {
        case let .success(value): issues = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await releasesResult {
        case let .success(value): releases = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await workflowsResult {
        case let .success(value): workflows = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await commitsResult {
        case let .success(value): commits = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await discussionsResult {
        case let .success(value): discussions = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await tagsResult {
        case let .success(value): tags = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await branchesResult {
        case let .success(value): branches = value
        case let .failure(error): self.error = error.userFacingMessage
        }
        switch await contributorsResult {
        case let .success(value): contributors = value
        case let .failure(error): self.error = error.userFacingMessage
        }
    }

    private func capture<T>(_ work: @escaping () async throws -> T) async -> Result<T, Error> {
        do { return try await .success(work()) } catch { return .failure(error) }
    }
}
