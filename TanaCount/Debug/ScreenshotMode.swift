#if DEBUG
import Foundation
import SwiftData

/// App Store用スクリーンショットを撮るための起動引数（DEBUGビルドのみ）。
/// 例: `xcrun simctl launch <端末> com.sidebiz.tanacount -screenshot edit`
enum ScreenshotMode: String {
    case list
    case edit

    static let current: ScreenshotMode? = {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-screenshot"), arguments.indices.contains(index + 1) else { return nil }
        return ScreenshotMode(rawValue: arguments[index + 1])
    }()

    /// サンプル品目を入れたメモリ上のストア。実データには触れない
    @MainActor
    static func makeContainer() -> ModelContainer {
        let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let samples = [
            ("ボールペン 黒 0.5mm", 24), ("ボールペン 赤 0.5mm", 18), ("A4コピー用紙 500枚", 7),
            ("付箋 75mm 黄", 32), ("ノート B5 6号", 15), ("クリアファイル 10枚入", 9),
            ("油性マーカー 黒", 12), ("ホチキス針 No.10", 40),
        ]
        for (offset, sample) in samples.enumerated() {
            let body = "45999000010\(offset)"
            container.mainContext.insert(Item(name: sample.0, janCode: body + String(JAN.checkDigit(for: body)), count: sample.1))
        }
        return container
    }
}
#endif
