import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(ProStore.self) private var store
    @Query(sort: \Item.name) private var items: [Item]

    @State private var searchText = ""
    @State private var isScanning = false
    @State private var isAdding = false
    @State private var editingItem: Item?
    @State private var isShowingPaywall = false
    @State private var isConfirmingReset = false

    private var filteredItems: [Item] {
        guard !searchText.isEmpty else { return items }
        return items.filter {
            $0.name.localizedStandardContains(searchText) || ($0.janCode?.contains(searchText) ?? false)
        }
    }

    private var csvFile: CSVFile {
        let rows = items.map { CSVRow(name: $0.name, janCode: $0.janCode, count: $0.count, updatedAt: $0.updatedAt) }
        return CSVFile(data: CSVExporter.makeData(rows: rows), fileName: CSVExporter.fileName())
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems) { item in
                    ItemRow(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture { editingItem = item }
                }
                .onDelete { offsets in
                    let targets = offsets.map { filteredItems[$0] }
                    targets.forEach(context.delete)
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView(
                        "品目がありません",
                        systemImage: "shippingbox",
                        description: Text("右上の＋で追加するか、バーコードを読み取ってください")
                    )
                }
            }
            .searchable(text: $searchText, prompt: "品名・JANで検索")
            .safeAreaInset(edge: .bottom) { bottomBar }
            .navigationTitle("棚卸カウンター")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { menu }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("品目を追加", systemImage: "plus") { isAdding = true }
                }
            }
            .fullScreenCover(isPresented: $isScanning) { ScanView() }
            .sheet(isPresented: $isAdding) { ItemEditView() }
            .sheet(item: $editingItem) { ItemEditView(item: $0) }
            .sheet(isPresented: $isShowingPaywall) { PaywallView() }
            .confirmationDialog("すべての数量を0に戻しますか？", isPresented: $isConfirmingReset, titleVisibility: .visible) {
                Button("0に戻す", role: .destructive) {
                    items.forEach { $0.adjust(by: -$0.count) }
                }
            } message: {
                Text("品目は残ります。新しい棚卸を始めるときに使います。")
            }
        }
    }

    private var menu: some View {
        Menu("メニュー", systemImage: "ellipsis.circle") {
            if store.isPro {
                ShareLink(item: csvFile, preview: SharePreview(csvFile.fileName)) {
                    Label("CSVで書き出す", systemImage: "square.and.arrow.up")
                }
                .disabled(items.isEmpty)
            } else {
                Button("CSVで書き出す（プロ版）", systemImage: "lock") { isShowingPaywall = true }
            }
            Button("数量をすべて0に戻す", systemImage: "arrow.counterclockwise", role: .destructive) {
                isConfirmingReset = true
            }
            .disabled(items.isEmpty)
            if !store.isPro {
                Section {
                    Button("プロ版について", systemImage: "star") { isShowingPaywall = true }
                }
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(items.count)品目")
                Spacer()
                Text("合計 \(items.reduce(0) { $0 + $1.count })")
            }
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(.secondary)

            Button {
                isScanning = true
            } label: {
                Label("バーコードで数える", systemImage: "barcode.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(.bar)
    }
}

struct ItemRow: View {
    let item: Item

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                Text(item.janCode ?? "JAN未登録")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("減らす", systemImage: "minus.circle") { item.adjust(by: -1) }
                .labelStyle(.iconOnly)
                .font(.title2)
                .disabled(item.count == 0)
            Text("\(item.count)")
                .font(.title3.monospacedDigit().bold())
                .frame(minWidth: 44)
            Button("増やす", systemImage: "plus.circle.fill") { item.adjust(by: 1) }
                .labelStyle(.iconOnly)
                .font(.title2)
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.selection, trigger: item.count)
    }
}
