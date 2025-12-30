import Foundation
@testable import RepoBarCore
import Testing

struct LocalGitServiceTests {
    @Test
    func createBranch_createsAndSwitches() async throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let repo = root.appendingPathComponent("repo", isDirectory: true)
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
        try initializeRepo(at: repo)

        try LocalGitService().createBranch(at: repo, name: "feature/test")

        let branch = try runGit(["rev-parse", "--abbrev-ref", "HEAD"], in: repo)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(branch == "feature/test")
    }

    @Test
    func createWorktree_createsNewWorktree() async throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let repo = root.appendingPathComponent("repo", isDirectory: true)
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
        try initializeRepo(at: repo)

        let worktree = root.appendingPathComponent("repo-worktree", isDirectory: true)
        try LocalGitService().createWorktree(at: repo, path: worktree, branch: "feature/worktree")

        #expect(FileManager.default.fileExists(atPath: worktree.path))
        let branch = try runGit(["rev-parse", "--abbrev-ref", "HEAD"], in: worktree)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(branch == "feature/worktree")
    }

    @Test
    func cloneRepo_clonesIntoDestination() async throws {
        let root = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let origin = root.appendingPathComponent("origin", isDirectory: true)
        try FileManager.default.createDirectory(at: origin, withIntermediateDirectories: true)
        try initializeRepo(at: origin)

        let destination = root.appendingPathComponent("clone", isDirectory: true)
        let remoteURL = origin
        try LocalGitService().cloneRepo(remoteURL: remoteURL, to: destination)

        let isRepo = try runGit(["rev-parse", "--is-inside-work-tree"], in: destination)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(isRepo == "true")
    }
}

private func makeTempDirectory() throws -> URL {
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("repobar-localgit-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

@discardableResult
private func runGit(_ arguments: [String], in directory: URL) throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.currentDirectoryURL = directory
    process.arguments = arguments

    let out = Pipe()
    let err = Pipe()
    process.standardOutput = out
    process.standardError = err

    try process.run()
    process.waitUntilExit()

    let output = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let error = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    if process.terminationStatus != 0 {
        throw GitTestError.commandFailed(arguments: arguments, output: output, error: error)
    }
    return output
}

private func initializeRepo(at url: URL) throws {
    try runGit(["init"], in: url)
    try runGit(["switch", "-c", "main"], in: url)
    try runGit(["config", "user.email", "repobar-tests@example.com"], in: url)
    try runGit(["config", "user.name", "RepoBar Tests"], in: url)
    let readme = url.appendingPathComponent("README.md")
    try Data("test\n".utf8).write(to: readme, options: .atomic)
    try runGit(["add", "."], in: url)
    try runGit(["commit", "-m", "init"], in: url)
}

private enum GitTestError: Error {
    case commandFailed(arguments: [String], output: String, error: String)
}
