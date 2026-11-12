import SwiftUI

struct SSLCheckerView: View {
    @State private var host = "google.com"
    @State private var port: Int32 = 443
    @State private var isChecking = false
    @State private var result: SSLResult?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "globe").foregroundColor(.cyan)
                            TextField("Host (masalan: google.com)", text: $host)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        HStack {
                            Image(systemName: "number").foregroundColor(.cyan)
                            TextField("Port", value: $port, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                    .padding().background(Color(.systemGray6)).cornerRadius(12).padding(.horizontal)

                    Button(action: checkSSL) {
                        HStack {
                            if isChecking {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Image(systemName: "lock.shield")
                            Text(isChecking ? "Tekshirilmoqda..." : "SSL tekshirish")
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(isChecking || host.isEmpty ? Color.gray : Color.cyan)
                        .foregroundColor(.white).cornerRadius(12)
                    }
                    .disabled(isChecking || host.isEmpty).padding(.horizontal)

                    if let ssl = result {
                        SSLResultCard(result: ssl).padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("SSL tekshiruvi")
            .alert("Xato", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage) }
        }
    }

    private func checkSSL() {
        guard !host.isEmpty else {
            errorMessage = "Host manzilini kiriting"
            showError = true
            return
        }
        isChecking = true
        result = nil
        DispatchQueue.global(qos: .userInitiated).async {
            let sslResult = RustBridge.checkSSL(host: host, port: port)
            DispatchQueue.main.async {
                result = sslResult
                isChecking = false
                if sslResult == nil {
                    errorMessage = "SSL tekshiruvi amalga oshmadi"
                    showError = true
                }
            }
        }
    }
}

struct SSLResultCard: View {
    let result: SSLResult
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: result.isValid ? "checkmark.shield.fill" : "xmark.shield.fill")
                    .font(.largeTitle)
                    .foregroundColor(result.isValid ? .green : .red)
                VStack(alignment: .leading) {
                    Text(result.isValid ? "Sertifikat yaroqli" : "Sertifikat xato")
                        .font(.headline)
                    Text("\(result.host):\(result.port)")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
            }
            Divider()
            if let issuer = result.issuer { SSLInfoRow(icon: "signature", title: "Issuer", value: issuer) }
            if let subject = result.subject { SSLInfoRow(icon: "person.fill", title: "Subject", value: subject) }
            if let version = result.protocolVersion { SSLInfoRow(icon: "network", title: "Protocol", value: version) }
            if let cipher = result.cipherSuite { SSLInfoRow(icon: "key.fill", title: "Cipher", value: cipher) }
            if let days = result.daysUntilExpiry {
                HStack {
                    Image(systemName: "calendar").foregroundColor(.cyan).frame(width: 24)
                    Text("Muddat:").foregroundColor(.secondary)
                    Spacer()
                    Text("\(days) kun")
                        .fontWeight(.medium)
                        .foregroundColor(days < 30 ? .orange : .green)
                }
            }
            if !result.warnings.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ogohlantirishlar").font(.headline).foregroundColor(.orange)
                    ForEach(result.warnings, id: \.self) { warning in
                        HStack(alignment: .top) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange).font(.caption)
                            Text(warning).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            if !result.errors.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Xatolar").font(.headline).foregroundColor(.red)
                    ForEach(result.errors, id: \.self) { error in
                        HStack(alignment: .top) {
                            Image(systemName: "xmark.octagon.fill")
                                .foregroundColor(.red).font(.caption)
                            Text(error).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding().background(Color(.systemBackground)).cornerRadius(16).shadow(radius: 4)
    }
}

struct SSLInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.cyan).frame(width: 24)
            Text("\(title):").foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium).lineLimit(1)
        }
    }
}

#Preview { SSLCheckerView() }
