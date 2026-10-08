import SwiftData
import SwiftUI

/// 連続読み取り画面。登録済みのJANは+1、未登録なら品目登録へ。
/// 手入力欄はシミュレータ確認用と、キーボードとして動く外付けスキャナ用を兼ねる
struct ScanView: View {
    private struct UnknownCode: Identifiable {
        let id: String
    }

    private enum Message {
        case counted(name: String, count: Int)
        case invalid(String, JAN.ValidationError)
    }

    @Environment(\.dismiss) private var dismiss
    @Query private var items: [Item]

    @State private var message: Message?
    @State private var unknownCode: UnknownCode?
    @State private var lastScan: (code: String, at: Date)?
    @State private var countedTrigger = 0
    @State private var manualCode = ""
    @FocusState private var isManualFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                scannerArea
                VStack(spacing: 16) {
                    messageView
                    manualInput
                }
                .padding()
                .background(.bar)
            }
            .navigationTitle("バーコードで数える")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
            .sheet(item: $unknownCode) { code in
                ItemEditView(initialJAN: code.id, initialCount: 1)
            }
            .sensoryFeedback(.increase, trigger: countedTrigger)
        }
    }

    @ViewBuilder
    private var scannerArea: some View {
        if BarcodeScanner.isAvailable {
            BarcodeScanner(onScan: handle)
                .ignoresSafeArea(edges: .horizontal)
        } else {
            ContentUnavailableView(
                "カメラで読み取れません",
                systemImage: "camera.badge.ellipsis",
                description: Text("この端末ではカメラ読み取りを使えません。下の欄にJANを入力してください。")
            )
            .frame(maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var messageView: some View {
        switch message {
        case .counted(let name, let count):
            Label {
                Text("\(name)　→ \(count)")
                    .font(.title3.bold().monospacedDigit())
            } icon: {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            }
        case .invalid(let raw, let error):
            Label("\(raw): \(error.message)", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        case nil:
            Text("JANバーコードにカメラを向けてください")
                .foregroundStyle(.secondary)
        }
    }

    private var manualInput: some View {
        HStack {
            TextField("JANを手入力", text: $manualCode)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .monospacedDigit()
                .focused($isManualFocused)
                .onSubmit(submitManual)
            Button("数える", action: submitManual)
                .buttonStyle(.bordered)
                .disabled(manualCode.isEmpty)
        }
    }

    private func submitManual() {
        let code = manualCode
        manualCode = ""
        lastScan = nil
        handle(code)
    }

    private func handle(_ raw: String) {
        guard unknownCode == nil else { return }
        let code: String
        switch JAN.validate(raw) {
        case .success(let normalized):
            code = normalized
        case .failure(let error):
            message = .invalid(raw, error)
            return
        }
        // 同じバーコードの読み取り揺れで二重に数えないようにする
        if let lastScan, lastScan.code == code, Date.now.timeIntervalSince(lastScan.at) < 1.0 { return }
        lastScan = (code, .now)

        if let item = items.first(where: { $0.janCode == code }) {
            item.adjust(by: 1)
            message = .counted(name: item.name, count: item.count)
            countedTrigger += 1
        } else {
            unknownCode = UnknownCode(id: code)
        }
    }
}
