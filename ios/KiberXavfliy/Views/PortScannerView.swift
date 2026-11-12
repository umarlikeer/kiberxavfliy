import SwiftUI

struct PortScannerView: View {
    @State private var host = "127.0.0.1"
    @State private var startPort: Int32 = 1
    @State private var endPort: Int32 = 1000
    @State private var timeout: Int32 = 500
    @State private var isScanning = false
    @State private var result: ScanResult?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Port skaneri").font(.headline).foregroundColor(.cyan)
                    HStack {
                        Text("Host:").frame(width: 80, alignment: .leading)
                        TextField("127.0.0.1", text: $host)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
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
                        }
                        Image(systemName: "number")
                        Text(isScanning ? "Skanerlanmoqda..." : "Portlarni skanerlash")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(isScanning || host.isEmpty ? Color.gray : Color.cyan)
                    .foregroundColor(.white).cornerRadius(12)
                }
                .disabled(isScanning || host.isEmpty).padding(.horizontal)

                if let scanResult = result {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Natijalar").font(.headline).foregroundColor(.cyan)
                            Spacer()
                            Text("\(scanResult.openPorts.count) ochiq")
                                .font(.caption).foregroundColor(.secondary)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color.cyan.opacity(0.2)).cornerRadius(8)
                        }
                        Text("Vaqt: \(scanResult.scanDurationMs)ms | Skanerlangan: \(scanResult.totalScanned)")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    List(scanResult.openPorts) { port in PortDetailRow(port: port) }
                        .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Port skaneri")
            .alert("Xato", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage) }
        }
    }

    private func startScan() {
        guard !host.isEmpty else {
            errorMessage = "Host manzilini kiriting"
            showError = true
            return
        }
        isScanning = true
        result = nil
        DispatchQueue.global(qos: .userInitiated).async {
            let scanResult = RustBridge.scanPorts(host: host, startPort: startPort,
                                                   endPort: endPort, timeoutMs: timeout)
            DispatchQueue.main.async {
                result = scanResult
                isScanning = false
                if scanResult == nil {
                    errorMessage = "Port skaneri amalga oshmadi"
                    showError = true
                }
            }
        }
    }
}

struct PortDetailRow: View {
    let port: PortInfo
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Port \(port.port)").font(.headline)
                    if port.service != "Unknown" {
                        Text(port.service)
                            .font(.caption).foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Color.cyan).cornerRadius(4)
                    }
                }
                if let banner = port.banner {
                    Text(banner).font(.caption).foregroundColor(.gray).lineLimit(1)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Circle().fill(Color.green).frame(width: 10, height: 10)
                Text("\(port.responseTimeMs)ms").font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview { PortScannerView() }
