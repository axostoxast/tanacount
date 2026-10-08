import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProStore.self) private var store

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "tablecells")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("プロ版")
                    .font(.largeTitle.bold())
                VStack(alignment: .leading, spacing: 12) {
                    Label("棚卸結果をCSVで書き出し", systemImage: "square.and.arrow.up")
                    Label("Excelやスプレッドシートでそのまま開ける", systemImage: "doc.text")
                    Label("一度の購入でずっと使える", systemImage: "checkmark.seal")
                }
                Spacer()
                Button {
                    Task { await store.purchase() }
                } label: {
                    Text(store.product.map { "\($0.displayPrice)で購入" } ?? "読み込み中…")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(store.product == nil || store.isPurchasing)

                Button("購入を復元") {
                    Task { await store.restore() }
                }
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .onChange(of: store.isPro) { _, isPro in
                if isPro { dismiss() }
            }
        }
    }
}
