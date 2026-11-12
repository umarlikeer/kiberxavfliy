import SwiftUI

struct SecurityTipsView: View {
    @State private var tips: [SecurityTip] = []
    @State private var selectedCategory = "Barchasi"
    @State private var searchText = ""
    let categories = ["Barchasi", "Parollar", "Autentifikatsiya", "Yangilanishlar",
                      "Phishing", "Zaxira", "Tarmoq", "Antivirus", "Maxfiylik"]

    var filteredTips: [SecurityTip] {
        var result = tips
        if selectedCategory != "Barchasi" { result = result.filter { $0.category == selectedCategory } }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Qidirish...", text: $searchText)
                }
                .padding().background(Color(.systemGray6)).cornerRadius(12)
                .padding(.horizontal).padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(selectedCategory == category ? .bold : .regular)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(selectedCategory == category ? Color.cyan : Color(.systemGray5))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                List(filteredTips) { tip in SecurityTipRow(tip: tip) }
                    .listStyle(PlainListStyle())
            }
            .navigationTitle("Xavfsizlik maslahatlari")
            .onAppear { loadTips() }
        }
    }

    private func loadTips() {
        tips = RustBridge.securityTips()
    }
}

struct SecurityTipRow: View {
    let tip: SecurityTip
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForPriority(tip.priority))
                    .foregroundColor(colorForPriority(tip.priority))
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(tip.title).font(.headline)
                    HStack {
                        Text(tip.category).font(.caption).foregroundColor(.secondary)
                        Text("•").foregroundColor(.secondary)
                        Text(priorityLabel(tip.priority))
                            .font(.caption).fontWeight(.medium)
                            .foregroundColor(colorForPriority(tip.priority))
                    }
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary).font(.caption)
            }
            if isExpanded {
                Text(tip.description)
                    .font(.subheadline).foregroundColor(.secondary)
                    .padding(.leading, 36)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
        }
    }

    private func iconForPriority(_ priority: String) -> String {
        switch priority {
        case "high": return "exclamationmark.triangle.fill"
        case "medium": return "exclamationmark.circle.fill"
        default: return "checkmark.circle.fill"
        }
    }
    private func colorForPriority(_ priority: String) -> Color {
        switch priority {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }
    private func priorityLabel(_ priority: String) -> String {
        switch priority {
        case "high": return "Muhim"
        case "medium": return "O'rtacha"
        default: return "Past"
        }
    }
}

#Preview { SecurityTipsView() }
