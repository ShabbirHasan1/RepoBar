import Kingfisher
import RepoBarCore
import SwiftUI

struct PullRequestMenuItemView: View {
    let model: PullRequestMenuRowViewModel
    let onOpen: () -> Void
    @Environment(\.menuItemHighlighted) private var isHighlighted

    var body: some View {
        RecentItemRowView(alignment: .top, onOpen: self.onOpen) {
            self.avatar
        } content: {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.model.title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(MenuHighlightStyle.primary(self.isHighlighted))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text("#\(self.model.number)")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                        .lineLimit(1)

                    if let author = self.model.authorLogin, author.isEmpty == false {
                        Text(author)
                            .font(.caption)
                            .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                            .lineLimit(1)
                    }

                    Text(RelativeFormatter.string(from: self.model.updatedAt, relativeTo: Date()))
                        .font(.caption2)
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                        .lineLimit(1)

                    Spacer(minLength: 2)

                    if self.model.isDraft {
                        DraftPillView(isHighlighted: self.isHighlighted)
                    }

                    if self.model.reviewCommentCount > 0 {
                        MenuStatBadge(label: nil, value: self.model.reviewCommentCount, systemImage: "checkmark.bubble")
                    }

                    if self.model.commentCount > 0 {
                        MenuStatBadge(label: nil, value: self.model.commentCount, systemImage: "text.bubble")
                    }
                }

                if let head = self.model.headRefName, let base = self.model.baseRefName, head.isEmpty == false, base.isEmpty == false {
                    Text("\(head) → \(base)")
                        .font(.caption2)
                        .monospaced()
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                        .lineLimit(1)
                }

                if self.model.labels.isEmpty == false {
                    MenuLabelChipsView(labels: self.model.labels)
                }
            }
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let url = self.model.authorAvatarURL {
            KFImage(url)
                .placeholder { self.avatarPlaceholder }
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .clipShape(Circle())
        } else {
            self.avatarPlaceholder
                .frame(width: 20, height: 20)
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color(nsColor: .separatorColor))
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            )
    }
}

private struct DraftPillView: View {
    let isHighlighted: Bool

    var body: some View {
        Text("Draft")
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(self.isHighlighted ? .white.opacity(0.95) : Color(nsColor: .systemOrange))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule(style: .continuous)
                    .fill(self.isHighlighted ? .white.opacity(0.16) : Color(nsColor: .systemOrange).opacity(0.14))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(self.isHighlighted ? .white.opacity(0.30) : Color(nsColor: .systemOrange).opacity(0.55), lineWidth: 1)
            )
    }
}
