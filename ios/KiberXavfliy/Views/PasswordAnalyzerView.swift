import SwiftUI

struct PasswordAnalyzerView: View {
    @State private var password = ""
    @State private var details: PasswordDetails?
    @State private var generatedPassword = ""
    @State private var passwordLength: Double = 16
    @State private var includeSpecial = true
    @State private var showCopied = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "key.fill").foregroundColor(.cyan)
                            SecureField("Parolni kiriting", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        if !password.isEmpty, let details = details {
                            PasswordStrengthBar(score: details.score)
                            Text(details.strengthLabel)
                                .font(.headline)
                                .foregroundColor(strengthColor(details.score))
                            Text("Kriptanaliz vaqti: \(details.timeToCrack)")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding().background(Color(.systemGray6)).cornerRadius(12).padding(.horizontal)
                    .onChange(of: password) { newValue in analyzePassword() }

                    if let details = details {
                        PasswordDetailsCard(details: details).padding(.horizontal)
                    }

                    VStack(spacing: 16) {
                        Text("Parol generatori").font(.headline).foregroundColor(.cyan)
                        HStack {
                            Text("Uzunlik: \(Int(passwordLength))").frame(width: 100, alignment: .leading)
                            Slider(value: $passwordLength, in: 8...64, step: 1)
                        }
                        Toggle("Maxsus belgilar", isOn: $includeSpecial)
                        if !generatedPassword.isEmpty {
                            HStack {
                                Text(generatedPassword)
                                    .font(.system(.body, design: .monospaced))
                                    .padding().background(Color(.systemGray5)).cornerRadius(8)
                                Button(action: copyPassword) {
                                    Image(systemName: "doc.on.doc").foregroundColor(.cyan)
                                }
                            }
                        }
                        Button(action: generatePassword) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Parol yaratish")
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.cyan).foregroundColor(.white).cornerRadius(12)
                        }
                    }
                    .padding().background(Color(.systemGray6)).cornerRadius(12).padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Parol analizatori")
            .overlay(
                Group {
                    if showCopied {
                        VStack {
                            Spacer()
                            Text("Nusxa olindi!")
                                .padding().background(Color.black.opacity(0.8))
                                .foregroundColor(.white).cornerRadius(8)
                                .padding(.bottom, 32)
                        }
                    }
                }
            )
        }
    }

    private func analyzePassword() {
        guard !password.isEmpty else { details = nil; return }
        details = RustBridge.passwordDetails(password)
    }
    private func generatePassword() {
        generatedPassword = RustBridge.generatePassword(length: Int32(passwordLength), includeSpecial: includeSpecial)
    }
    private func copyPassword() {
        UIPasteboard.general.string = generatedPassword
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showCopied = false }
    }
    private func strengthColor(_ score: Double) -> Color {
        switch score {
        case 0..<20: return .red
        case 20..<40: return .orange
        case 40..<60: return .yellow
        case 60..<80: return .green
        default: return .cyan
        }
    }
}

struct PasswordStrengthBar: View {
    let score: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray4)).frame(height: 8)
                RoundedRectangle(cornerRadius: 4).fill(barColor)
                    .frame(width: geometry.size.width * CGFloat(score / 100.0), height: 8)
                    .animation(.easeInOut(duration: 0.3), value: score)
            }
        }
        .frame(height: 8)
    }
    private var barColor: Color {
        switch score {
        case 0..<20: return .red
        case 20..<40: return .orange
        case 40..<60: return .yellow
        case 60..<80: return .green
        default: return .cyan
        }
    }
}

struct PasswordDetailsCard: View {
    let details: PasswordDetails
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tafsilotlar").font(.headline).foregroundColor(.cyan)
            HStack {
                PasswordCheckRow(icon: "textformat.abc", title: "Kichik harflar", isValid: details.hasLowercase)
                PasswordCheckRow(icon: "textformat.abc.dottedunderline", title: "Katta harflar", isValid: details.hasUppercase)
            }
            HStack {
                PasswordCheckRow(icon: "number", title: "Raqamlar", isValid: details.hasDigits)
                PasswordCheckRow(icon: "exclamationmark", title: "Maxsus belgilar", isValid: details.hasSpecial)
            }
            Divider()
            HStack { Text("Uzunlik:").foregroundColor(.secondary); Spacer(); Text("\(details.length)").fontWeight(.medium) }
            HStack { Text("Noyob belgilar:").foregroundColor(.secondary); Spacer(); Text("\(details.uniqueChars)").fontWeight(.medium) }
            if !details.suggestions.isEmpty {
                Divider()
                Text("Maslahatlar").font(.subheadline).foregroundColor(.orange)
                ForEach(details.suggestions, id: \.self) { suggestion in
                    HStack(alignment: .top) {
                        Image(systemName: "lightbulb.fill").foregroundColor(.orange).font(.caption)
                        Text(suggestion).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding().background(Color(.systemBackground)).cornerRadius(16).shadow(radius: 4)
    }
}

struct PasswordCheckRow: View {
    let icon: String
    let title: String
    let isValid: Bool
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview { PasswordAnalyzerView() }
