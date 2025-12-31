import SwiftUI

struct ChangelogMenuView: View {
    let content: ChangelogContent

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

            ScrollView(.vertical) {
                MarkdownTextView(
                    markdown: self.content.markdown,
                    isHighlighted: self.isHighlighted
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: MenuStyle.changelogPreviewHeight)

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
    let isHighlighted: Bool

    var body: some View {
        Text(self.attributedText)
            .font(.caption)
            .foregroundStyle(MenuHighlightStyle.primary(self.isHighlighted))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributedText: AttributedString {
        if let parsed = try? AttributedString(markdown: self.markdown) {
            return parsed
        }
        var inlineOptions = AttributedString.MarkdownParsingOptions()
        inlineOptions.interpretedSyntax = .inlineOnlyPreservingWhitespace
        if let parsed = try? AttributedString(markdown: self.markdown, options: inlineOptions) {
            return parsed
        }
        return AttributedString(self.markdown)
    }
}
