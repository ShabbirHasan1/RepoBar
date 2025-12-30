import SwiftUI

struct LocalWorktreeMenuRowView: View {
    let path: String
    let branch: String
    let isCurrent: Bool
    let upstream: String?
    let aheadCount: Int?
    let behindCount: Int?
    let lastCommitDate: Date?
    let lastCommitAuthor: String?
    let dirtySummary: String?

    @Environment(\.menuItemHighlighted) private var isHighlighted

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            self.headerRow
            self.metadataRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }

    private var headerRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: MenuStyle.submenuIconSpacing) {
            SubmenuIconColumnView {
                Image(systemName: self.isCurrent ? "checkmark" : "circle")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
            }

            Text(self.path)
                .font(.system(size: 13))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: 8)

            if let dirtySummary, !dirtySummary.isEmpty {
                Text("Dirty \(dirtySummary)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                    .lineLimit(1)
            }

            Text(self.branch)
                .font(.caption2)
                .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                .lineLimit(1)
        }
    }

    private var metadataRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: MenuStyle.submenuIconSpacing) {
            Text(" ")
                .font(.caption2)
                .frame(width: MenuStyle.submenuIconColumnWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                if let upstream {
                    Text("Tracking \(upstream)")
                        .font(.caption2)
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                        .lineLimit(1)
                }

                if let commitLine {
                    Text(commitLine)
                        .font(.caption2)
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            let syncLabel = self.syncLabel
            if syncLabel.isEmpty == false {
                Text(syncLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                    .lineLimit(1)
            }
        }
    }

    private var syncLabel: String {
        let ahead = self.aheadCount ?? 0
        let behind = self.behindCount ?? 0
        guard ahead > 0 || behind > 0 else { return "" }
        var parts: [String] = []
        if ahead > 0 { parts.append("↑\(ahead)") }
        if behind > 0 { parts.append("↓\(behind)") }
        return parts.joined(separator: " ")
    }

    private var commitLine: String? {
        guard let lastCommitDate, let lastCommitAuthor else { return nil }
        let when = RelativeFormatter.string(from: lastCommitDate, relativeTo: Date())
        return "\(lastCommitAuthor) · \(when)"
    }
}
