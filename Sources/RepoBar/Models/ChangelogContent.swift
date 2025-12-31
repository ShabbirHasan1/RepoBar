import Foundation

enum ChangelogSource: Equatable, Sendable {
    case local
    case remote

    var label: String {
        switch self {
        case .local: "Local"
        case .remote: "GitHub"
        }
    }
}

struct ChangelogContent: Equatable, Sendable {
    let fileName: String
    let markdown: String
    let source: ChangelogSource
    let isTruncated: Bool
}
