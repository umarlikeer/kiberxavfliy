import Foundation

class RustBridge {
    static let shared = RustBridge()
    private static var isInitialized = false

    static func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        print("KiberXavfliy Core v\(version()) yuklandi")
    }

    static func version() -> String {
        guard let ptr = kx_version() else { return "unknown" }
        let str = String(cString: ptr)
        kx_free_string(ptr)
        return str
    }

    static func scanNetwork(baseIP: String, startPort: Int32, endPort: Int32, timeoutMs: Int32) -> [ScanResult] {
        let cBaseIP = strdup(baseIP)
        defer { free(cBaseIP) }
        guard let ptr = kx_scan_network(cBaseIP, startPort, endPort, timeoutMs) else { return [] }
        let json = String(cString: ptr)
        kx_free_string(ptr)
        do {
            let data = json.data(using: .utf8)!
            return try JSONDecoder().decode([ScanResult].self, from: data)
        } catch {
            print("Scan decode error: \(error)")
            return []
        }
    }

    static func scanPorts(host: String, startPort: Int32, endPort: Int32, timeoutMs: Int32) -> ScanResult? {
        let cHost = strdup(host)
        defer { free(cHost) }
        guard let ptr = kx_scan_ports(cHost, startPort, endPort, timeoutMs) else { return nil }
        let json = String(cString: ptr)
        kx_free_string(ptr)
        do {
            let data = json.data(using: .utf8)!
            return try JSONDecoder().decode(ScanResult.self, from: data)
        } catch {
            print("Port scan decode error: \(error)")
            return nil
        }
    }

    static func checkSSL(host: String, port: Int32) -> SSLResult? {
        let cHost = strdup(host)
        defer { free(cHost) }
        guard let ptr = kx_check_ssl(cHost, port) else { return nil }
        let json = String(cString: ptr)
        kx_free_string(ptr)
        do {
            let data = json.data(using: .utf8)!
            return try JSONDecoder().decode(SSLResult.self, from: data)
        } catch {
            print("SSL decode error: \(error)")
            return nil
        }
    }

    static func analyzePassword(_ password: String) -> Double {
        let cPassword = strdup(password)
        defer { free(cPassword) }
        return kx_analyze_password(cPassword)
    }

    static func passwordDetails(_ password: String) -> PasswordDetails? {
        let cPassword = strdup(password)
        defer { free(cPassword) }
        guard let ptr = kx_password_details(cPassword) else { return nil }
        let json = String(cString: ptr)
        kx_free_string(ptr)
        do {
            let data = json.data(using: .utf8)!
            return try JSONDecoder().decode(PasswordDetails.self, from: data)
        } catch {
            print("Password decode error: \(error)")
            return nil
        }
    }

    static func sha256(_ input: String) -> String {
        let cInput = strdup(input)
        defer { free(cInput) }
        guard let ptr = kx_sha256(cInput) else { return "" }
        let result = String(cString: ptr)
        kx_free_string(ptr)
        return result
    }

    static func md5(_ input: String) -> String {
        let cInput = strdup(input)
        defer { free(cInput) }
        guard let ptr = kx_md5(cInput) else { return "" }
        let result = String(cString: ptr)
        kx_free_string(ptr)
        return result
    }

    static func base64Encode(_ input: String) -> String {
        let cInput = strdup(input)
        defer { free(cInput) }
        guard let ptr = kx_base64_encode(cInput) else { return "" }
        let result = String(cString: ptr)
        kx_free_string(ptr)
        return result
    }

    static func base64Decode(_ input: String) -> String? {
        let cInput = strdup(input)
        defer { free(cInput) }
        guard let ptr = kx_base64_decode(cInput) else { return nil }
        let result = String(cString: ptr)
        kx_free_string(ptr)
        return result
    }

    static func generatePassword(length: Int32, includeSpecial: Bool) -> String {
        guard let ptr = kx_generate_password(length, includeSpecial ? 1 : 0) else { return "" }
        let result = String(cString: ptr)
        kx_free_string(ptr)
        return result
    }

    static func securityTips() -> [SecurityTip] {
        guard let ptr = kx_security_tips() else { return [] }
        let json = String(cString: ptr)
        kx_free_string(ptr)
        do {
            let data = json.data(using: .utf8)!
            return try JSONDecoder().decode([SecurityTip].self, from: data)
        } catch {
            print("Tips decode error: \(error)")
            return []
        }
    }

    static func ipInfo(_ ip: String) -> IpInfo? {
        let cIP = strdup(ip)
        defer { free(cIP) }
        guard let ptr = kx_ip_info(cIP) else { return nil }
        let json = String(cString: ptr)
        kx_free_string(ptr)
        do {
            let data = json.data(using: .utf8)!
            return try JSONDecoder().decode(IpInfo.self, from: data)
        } catch {
            print("IP info decode error: \(error)")
            return nil
        }
    }
}
