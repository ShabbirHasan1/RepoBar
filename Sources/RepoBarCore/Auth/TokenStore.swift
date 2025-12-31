import Foundation
import Security

public struct OAuthTokens: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date?

    public init(accessToken: String, refreshToken: String, expiresAt: Date?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

public struct OAuthClientCredentials: Codable, Equatable, Sendable {
    public let clientID: String
    public let clientSecret: String

    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

public enum TokenStoreError: Error {
    case saveFailed
    case loadFailed
}

public struct TokenStore: Sendable {
    public static var shared: TokenStore { TokenStore() }
    private let service: String
    private let accessGroup: String?

    public init(
        service: String = "com.steipete.repobar.auth",
        accessGroup: String? = Self.defaultAccessGroup()
    ) {
        self.service = service
        self.accessGroup = accessGroup
    }

    public func save(tokens: OAuthTokens) throws {
        let data = try JSONEncoder().encode(tokens)
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "default",
            kSecValueData: data
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw TokenStoreError.saveFailed }
    }

    public func load() throws -> OAuthTokens? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "default",
            kSecReturnData: true
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else { throw TokenStoreError.loadFailed }
        return try JSONDecoder().decode(OAuthTokens.self, from: data)
    }

    public func save(clientCredentials: OAuthClientCredentials) throws {
        let data = try JSONEncoder().encode(clientCredentials)
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "client",
            kSecValueData: data
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw TokenStoreError.saveFailed }
    }

    public func loadClientCredentials() throws -> OAuthClientCredentials? {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "client",
            kSecReturnData: true
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else { throw TokenStoreError.loadFailed }
        return try JSONDecoder().decode(OAuthClientCredentials.self, from: data)
    }

    public func clear() {
        var tokenQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "default"
        ]
        if let accessGroup {
            tokenQuery[kSecAttrAccessGroup] = accessGroup
        }
        SecItemDelete(tokenQuery as CFDictionary)

        var clientQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "client"
        ]
        if let accessGroup {
            clientQuery[kSecAttrAccessGroup] = accessGroup
        }
        SecItemDelete(clientQuery as CFDictionary)
    }
}

private extension TokenStore {
    static let sharedAccessGroupSuffix = "com.steipete.repobar.shared"

    static func defaultAccessGroup() -> String? {
        guard let task = SecTaskCreateFromSelf(nil),
              let entitlement = SecTaskCopyValueForEntitlement(task, "keychain-access-groups" as CFString, nil)
        else {
            return nil
        }
        if let groups = entitlement as? [String] {
            return groups.first(where: { $0.hasSuffix(Self.sharedAccessGroupSuffix) })
        }
        return nil
    }
}
