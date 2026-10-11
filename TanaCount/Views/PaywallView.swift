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
                if let product = store.product {
                    Button {
                        Task { await store.purchase() }
                    } label: {
                        Text("\(product.displayPrice)で購入")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(store.isPurchasing)
                } else if store.isLoadingProduct {
                    ProgressView("読み込み中…")
                        .frame(maxWidth: .infinity, minHeight: 50)
                } else {
                    Button {
                        Task { await store.load() }
                    } label: {
                        Label("再読み込み", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

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
            .task {
                if store.product == nil { await store.load() }
            }
        }
    }
}
