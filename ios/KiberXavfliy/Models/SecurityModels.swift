import Foundation

struct ScanResult: Codable {
    let host: String
    let ip: String
    let openPorts: [PortInfo]
    let scanDurationMs: UInt64
    let totalScanned: UInt32
    let osGuess: String?

    enum CodingKeys: String, CodingKey {
        case host, ip
        case openPorts = "open_ports"
        case scanDurationMs = "scan_duration_ms"
        case totalScanned = "total_scanned"
        case osGuess = "os_guess"
    }
}

struct PortInfo: Codable, Identifiable {
    let id = UUID()
    let port: UInt16
    let service: String
    let banner: String?
    let responseTimeMs: UInt64

    enum CodingKeys: String, CodingKey {
        case port, service, banner
        case responseTimeMs = "response_time_ms"
    }
}

struct SSLResult: Codable {
    let host: String
    let port: UInt16
    let isValid: Bool
    let issuer: String?
    let subject: String?
    let notBefore: String?
    let notAfter: String?
    let daysUntilExpiry: Int64?
    let protocolVersion: String?
    let cipherSuite: String?
    let hasValidChain: Bool
    let warnings: [String]
    let errors: [String]

    enum CodingKeys: String, CodingKey {
        case host, port
        case isValid = "is_valid"
        case issuer, subject
        case notBefore = "not_before"
        case notAfter = "not_after"
        case daysUntilExpiry = "days_until_expiry"
        case protocolVersion = "protocol_version"
        case cipherSuite = "cipher_suite"
        case hasValidChain = "has_valid_chain"
        case warnings, errors
    }
}

struct PasswordDetails: Codable {
    let score: Double
    let length: Int
    let hasLowercase: Bool
    let hasUppercase: Bool
    let hasDigits: Bool
    let hasSpecial: Bool
    let uniqueChars: Int
    let repeatedChars: Int
    let sequentialChars: Int
    let strengthLabel: String
    let timeToCrack: String
    let suggestions: [String]

    enum CodingKeys: String, CodingKey {
        case score, length
        case hasLowercase = "has_lowercase"
        case hasUppercase = "has_uppercase"
        case hasDigits = "has_digits"
        case hasSpecial = "has_special"
        case uniqueChars = "unique_chars"
        case repeatedChars = "repeated_chars"
        case sequentialChars = "sequential_chars"
        case strengthLabel = "strength_label"
        case timeToCrack = "time_to_crack"
        case suggestions
    }
}

struct SecurityTip: Codable, Identifiable {
    let id: UInt32
    let title: String
    let description: String
    let category: String
    let priority: String
}

struct IpInfo: Codable {
    let ip: String
    let isPrivate: Bool
    let isLoopback: Bool
    let isMulticast: Bool
    let version: String
    let `class`: String

    enum CodingKeys: String, CodingKey {
        case ip
        case isPrivate = "is_private"
        case isLoopback = "is_loopback"
        case isMulticast = "is_multicast"
        case version, class
    }
}

extension Double {
    func formattedScore() -> String {
        String(format: "%.1f", self)
    }
}
