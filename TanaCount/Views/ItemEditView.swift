import SwiftData
import SwiftUI

struct ItemEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private let item: Item?
    @State private var name: String
    @State private var janText: String
    @State private var count: Int
    @State private var isScanningJAN = false
    @State private var errorMessage: String?

    init(item: Item? = nil, initialJAN: String? = nil, initialCount: Int = 0) {
        self.item = item
        _name = State(initialValue: item?.name ?? "")
        _janText = State(initialValue: item?.janCode ?? initialJAN ?? "")
        _count = State(initialValue: item?.count ?? initialCount)
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section("品名") {
                    TextField("例: ボールペン 黒", text: $name)
                }
                Section("JANコード（任意）") {
                    HStack {
                        TextField("例: 4901234567894", text: $janText)
                            .keyboardType(.numberPad)
                            .monospacedDigit()
                        if BarcodeScanner.isAvailable {
                            Button("読み取る", systemImage: "barcode.viewfinder") { isScanningJAN = true }
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                Section("数量") {
                    Stepper(value: $count, in: 0...999_999) {
                        Text("\(count)").monospacedDigit()
                    }
                }
                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(item == nil ? "品目を追加" : "品目を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .sheet(isPresented: $isScanningJAN) {
                BarcodeScanner { code in
                    janText = code
                    isScanningJAN = false
                }
                .ignoresSafeArea()
            }
        }
    }

    private func save() {
        let rawJAN = janText.trimmingCharacters(in: .whitespacesAndNewlines)
        var janCode: String?
        if !rawJAN.isEmpty {
            let normalized: String
            switch JAN.validate(rawJAN) {
            case .success(let code):
                normalized = code
            case .failure(let error):
                errorMessage = error.message
                return
            }
            let descriptor = FetchDescriptor<Item>(predicate: #Predicate { $0.janCode == normalized })
            let duplicates = (try? context.fetch(descriptor)) ?? []
            if duplicates.contains(where: { $0.persistentModelID != item?.persistentModelID }) {
                errorMessage = "このJANコードはすでに登録されています"
                return
            }
            janCode = normalized
        }

        if let item {
            item.name = trimmedName
            item.janCode = janCode
            item.adjust(by: count - item.count)
        } else {
            context.insert(Item(name: trimmedName, janCode: janCode, count: count))
        }
        dismiss()
    }
}
