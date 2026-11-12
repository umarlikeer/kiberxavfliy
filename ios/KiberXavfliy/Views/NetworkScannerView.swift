import SwiftUI

struct NetworkScannerView: View {
    @State private var baseIP = "192.168.1"
    @State private var startPort: Int32 = 1
    @State private var endPort: Int32 = 100
    @State private var timeout: Int32 = 1000
    @State private var isScanning = false
    @State private var results: [ScanResult] = []
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tarmoq skaneri").font(.headline).foregroundColor(.cyan)
                    HStack {
                        Text("Base IP:").frame(width: 80, alignment: .leading)
                        TextField("192.168.1", text: $baseIP)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Portlar:").frame(width: 80, alignment: .leading)
                        TextField("Bosh", value: $startPort, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad).frame(width: 80)
                        Text("-")
                        TextField("Yakun", value: $endPort, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad).frame(width: 80)
                    }
                    HStack {
                        Text("Timeout:").frame(width: 80, alignment: .leading)
                        TextField("ms", value: $timeout, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad).frame(width: 100)
                        Text("ms").foregroundColor(.secondary)
                    }
                }
                .padding().background(Color(.systemGray6)).cornerRadius(12).padding(.horizontal)

                Button(action: startScan) {
                    HStack {
                        if isScanning {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Image(systemName: "network")
                        Text(isScanning ? "Skanerlanmoqda..." : "Skanerlash")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(isScanning ? Color.gray : Color.cyan)
                    .foregroundColor(.white).cornerRadius(12)
                }
                .disabled(isScanning).padding(.horizontal)

                if !results.isEmpty {
                    Text("Topilgan qurilmalar: \(results.count)")
                        .font(.subheadline).foregroundColor(.secondary).padding(.top, 8)
                }

                List(results) { result in
                    NavigationLink(destination: ScanDetailView(result: result)) {
                        ScanResultRow(result: result)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Tarmoq skaneri")
            .alert("Xato", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage) }
        }
    }

    private func startScan() {
        guard !baseIP.isEmpty else {
            errorMessage = "IP manzilni kiriting"
            showError = true
            return
        }
        isScanning = true
        results = []
        DispatchQueue.global(qos: .userInitiated).async {
            let scanResults = RustBridge.scanNetwork(baseIP: baseIP, startPort: startPort,
                                                      endPort: endPort, timeoutMs: timeout)
            DispatchQueue.main.async {
                results = scanResults
                isScanning = false
            }
        }
    }
}

struct ScanResultRow: View {
    let result: ScanResult
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "desktopcomputer").foregroundColor(.cyan)
                Text(result.ip).font(.headline)
                Spacer()
                Text("\(result.openPorts.count) port")
                    .font(.caption).foregroundColor(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.cyan.opacity(0.2)).cornerRadius(8)
            }
            if let os = result.osGuess {
                Text("OS: \(os)").font(.caption).foregroundColor(.secondary)
            }
            Text("Vaqt: \(result.scanDurationMs)ms | Skanerlangan: \(result.totalScanned)")
                .font(.caption2).foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct ScanDetailView: View {
    let result: ScanResult
    var body: some View {
        List {
            Section(header: Text("Qurilma ma'lumotlari")) {
                InfoRow(title: "IP", value: result.ip)
                InfoRow(title: "Host", value: result.host)
                if let os = result.osGuess { InfoRow(title: "OS Taxmini", value: os) }
                InfoRow(title: "Skanerlash vaqti", value: "\(result.scanDurationMs)ms")
            }
            Section(header: Text("Ochiq portlar (\(result.openPorts.count))")) {
                ForEach(result.openPorts) { port in PortRow(port: port) }
            }
        }
        .navigationTitle(result.ip)
    }
}

struct PortRow: View {
    let port: PortInfo
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Port \(port.port)").font(.headline)
                Text(port.service).font(.subheadline).foregroundColor(.secondary)
                if let banner = port.banner {
                    Text(banner).font(.caption).foregroundColor(.gray).lineLimit(2)
                }
            }
            Spacer()
            Text("\(port.responseTimeMs)ms").font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}

#Preview { NetworkScannerView() }
