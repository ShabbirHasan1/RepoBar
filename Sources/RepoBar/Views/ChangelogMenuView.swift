import SwiftUI

struct ChangelogMenuView: View {
    let content: ChangelogContent
    let lineLimit: Int

    @Environment(\.menuItemHighlighted) private var isHighlighted

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: MenuStyle.submenuIconSpacing) {
                SubmenuIconColumnView {
                    Image(systemName: "doc.text")
                        .symbolRenderingMode(.hierarchical)
                        .font(.caption)
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                }

                Text(self.content.fileName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MenuHighlightStyle.primary(self.isHighlighted))
                    .lineLimit(1)

                Text(self.content.source.label)
                    .font(.caption2)
                    .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            MarkdownTextView(
                markdown: self.content.markdown,
                lineLimit: self.lineLimit,
                isHighlighted: self.isHighlighted
            )

            if self.content.isTruncated {
                Text("Preview truncated")
                    .font(.caption2)
                    .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
            }
        }
        .padding(.horizontal, MenuStyle.cardHorizontalPadding)
        .padding(.vertical, MenuStyle.cardVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MarkdownTextView: View {
    let markdown: String
    let lineLimit: Int
    let isHighlighted: Bool

    var body: some View {
        Text(self.attributedText)
            .font(.caption)
            .foregroundStyle(MenuHighlightStyle.primary(self.isHighlighted))
            .lineLimit(self.lineLimit)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributedText: AttributedString {
        var options = AttributedString.MarkdownParsingOptions()
        options.interpretedSyntax = .inlineOnlyPreservingWhitespace
        if let parsed = try? AttributedString(markdown: self.markdown, options: options) {
            return parsed
        }
        return AttributedString(self.markdown)
    }
}
