import Foundation
@testable import RepoBarCore
import Testing

struct EventLabelTests {
    @Test
    func pullRequestEventHasReadableTitle() {
        let event = RepoEvent(
            type: "PullRequestEvent",
            actor: EventActor(login: "octo"),
            payload: EventPayload(action: nil, comment: nil, issue: nil, pullRequest: nil),
            createdAt: Date()
        )
        #expect(event.displayTitle == "Pull Request")
    }

    @Test
    func actionGetsAppendedToTitle() {
        let event = RepoEvent(
            type: "IssuesEvent",
            actor: EventActor(login: "octo"),
            payload: EventPayload(action: "opened", comment: nil, issue: nil, pullRequest: nil),
            createdAt: Date()
        )
        #expect(event.displayTitle == "Issue opened")
    }

    @Test
    func unknownEventTypeFallsBackToReadableName() {
        let event = RepoEvent(
            type: "ProjectCardEvent",
            actor: EventActor(login: "octo"),
            payload: EventPayload(action: nil, comment: nil, issue: nil, pullRequest: nil),
            createdAt: Date()
        )
        #expect(event.displayTitle == "Project Card")
    }
}
