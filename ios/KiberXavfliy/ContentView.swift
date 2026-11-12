import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NetworkScannerView()
                .tabItem { Label("Tarmoq", systemImage: "network") }
                .tag(0)
            SSLCheckerView()
                .tabItem { Label("SSL", systemImage: "lock.shield") }
                .tag(1)
            PasswordAnalyzerView()
                .tabItem { Label("Parol", systemImage: "key.fill") }
                .tag(2)
            PortScannerView()
                .tabItem { Label("Portlar", systemImage: "number") }
                .tag(3)
            SecurityTipsView()
                .tabItem { Label("Maslahatlar", systemImage: "lightbulb.fill") }
                .tag(4)
        }
        .accentColor(.cyan)
    }
}

#Preview {
    ContentView()
}
