// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension RepoBarGraphQL {
  struct RepoSnapshotQuery: GraphQLQuery {
    static let operationName: String = "RepoSnapshot"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query RepoSnapshot($owner: String!, $name: String!) { repository(owner: $owner, name: $name) { __typename name releases(last: 1, orderBy: { field: CREATED_AT, direction: DESC }) { __typename nodes { __typename name tagName publishedAt url } } issues(states: OPEN) { __typename totalCount } pullRequests(states: OPEN) { __typename totalCount } } }"#
      ))

    public var owner: String
    public var name: String

    public init(
      owner: String,
      name: String
    ) {
      self.owner = owner
      self.name = name
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "owner": owner,
      "name": name
    ] }

    struct Data: RepoBarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { RepoBarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("repository", Repository?.self, arguments: [
          "owner": .variable("owner"),
          "name": .variable("name")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RepoSnapshotQuery.Data.self
      ] }

      /// Lookup a given repository by the owner and repository name.
      var repository: Repository? { __data["repository"] }

      /// Repository
      ///
      /// Parent Type: `Repository`
      struct Repository: RepoBarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { RepoBarGraphQL.Objects.Repository }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("releases", Releases.self, arguments: [
            "last": 1,
            "orderBy": [
              "field": "CREATED_AT",
              "direction": "DESC"
            ]
          ]),
          .field("issues", Issues.self, arguments: ["states": "OPEN"]),
          .field("pullRequests", PullRequests.self, arguments: ["states": "OPEN"]),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          RepoSnapshotQuery.Data.Repository.self
        ] }

        /// The name of the repository.
        var name: String { __data["name"] }
        /// List of releases which are dependent on this repository.
        var releases: Releases { __data["releases"] }
        /// A list of issues that have been opened in the repository.
        var issues: Issues { __data["issues"] }
        /// A list of pull requests that have been opened in the repository.
        var pullRequests: PullRequests { __data["pullRequests"] }

        /// Repository.Releases
        ///
        /// Parent Type: `ReleaseConnection`
        struct Releases: RepoBarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepoBarGraphQL.Objects.ReleaseConnection }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?]?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            RepoSnapshotQuery.Data.Repository.Releases.self
          ] }

          /// A list of nodes.
          var nodes: [Node?]? { __data["nodes"] }

          /// Repository.Releases.Node
          ///
          /// Parent Type: `Release`
          struct Node: RepoBarGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { RepoBarGraphQL.Objects.Release }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", String?.self),
              .field("tagName", String.self),
              .field("publishedAt", RepoBarGraphQL.DateTime?.self),
              .field("url", RepoBarGraphQL.URI.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              RepoSnapshotQuery.Data.Repository.Releases.Node.self
            ] }

            /// The title of the release.
            var name: String? { __data["name"] }
            /// The name of the release's Git tag
            var tagName: String { __data["tagName"] }
            /// Identifies the date and time when the release was created.
            var publishedAt: RepoBarGraphQL.DateTime? { __data["publishedAt"] }
            /// The HTTP URL for this issue
            var url: RepoBarGraphQL.URI { __data["url"] }
          }
        }

        /// Repository.Issues
        ///
        /// Parent Type: `IssueConnection`
        struct Issues: RepoBarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepoBarGraphQL.Objects.IssueConnection }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("totalCount", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            RepoSnapshotQuery.Data.Repository.Issues.self
          ] }

          /// Identifies the total count of items in the connection.
          var totalCount: Int { __data["totalCount"] }
        }

        /// Repository.PullRequests
        ///
        /// Parent Type: `PullRequestConnection`
        struct PullRequests: RepoBarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepoBarGraphQL.Objects.PullRequestConnection }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("totalCount", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            RepoSnapshotQuery.Data.Repository.PullRequests.self
          ] }

          /// Identifies the total count of items in the connection.
          var totalCount: Int { __data["totalCount"] }
        }
      }
    }
  }

}