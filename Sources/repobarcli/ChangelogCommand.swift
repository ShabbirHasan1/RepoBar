import Commander
import Foundation
import RepoBarCore

struct ChangelogPresentationOutput: Codable {
    let title: String
    let badgeText: String?
    let detailText: String?
}

struct ChangelogSectionOutput: Codable {
    let title: String
    let entryCount: Int
}

struct ChangelogOutput: Codable {
    let sections: [ChangelogSectionOutput]
    let presentation: ChangelogPresentationOutput?
}

@MainActor
struct ChangelogCommand: CommanderRunnableCommand {
    nonisolated static let commandName = "changelog"

    @Option(name: .customLong("release"), help: "Release tag to compare against (ex: v1.0.0)")
    var releaseTag: String?

    @OptionGroup
    var output: OutputOptions

    private var path: String?

    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: commandName,
            abstract: "Parse a changelog and summarize entries"
        )
    }

    mutating func bind(_ values: ParsedValues) throws {
        self.releaseTag = try values.decodeOption("release")
        self.output.bind(values)

        if values.positional.count > 1 {
            throw ValidationError("Only one changelog file can be specified")
        }
        self.path = values.positional.first
    }

    mutating func run() async throws {
        guard let path, path.isEmpty == false else {
            throw ValidationError("Missing changelog file path")
        }

        let markdown = try String(contentsOfFile: path, encoding: .utf8)
        let parsed = ChangelogParser.parse(markdown: markdown)
        let presentation = ChangelogParser.presentation(parsed: parsed, releaseTag: releaseTag)

        let outputSections = parsed.sections.map { section in
            ChangelogSectionOutput(title: section.title, entryCount: section.entryCount)
        }
        let outputPresentation = presentation.map { presentation in
            ChangelogPresentationOutput(
                title: presentation.title,
                badgeText: presentation.badgeText,
                detailText: presentation.detailText
            )
        }

        if self.output.jsonOutput {
            try printJSON(ChangelogOutput(sections: outputSections, presentation: outputPresentation))
            return
        }

        print("Sections: \(outputSections.count)")
        for section in outputSections {
            print("- \(section.title) (\(section.entryCount))")
        }
        if let outputPresentation {
            print("Presentation: \(outputPresentation.title)")
            if let badge = outputPresentation.badgeText {
                print("Badge: \(badge)")
            }
            if let detail = outputPresentation.detailText {
                print("Detail: \(detail)")
            }
        } else {
            print("Presentation: -")
        }
    }
}
