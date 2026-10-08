import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct CSVRow: Sendable {
    let name: String
    let janCode: String?
    let count: Int
    let updatedAt: Date
}

enum CSVExporter {
    static let header = ["JANコード", "品名", "数量", "最終更新"]

    /// Excelで文字化けしないようUTF-8 BOM付き・CRLFで出力する
    static func makeData(rows: [CSVRow]) -> Data {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let lines = [header] + rows.map {
            [$0.janCode ?? "", $0.name, String($0.count), formatter.string(from: $0.updatedAt)]
        }
        let text = lines.map { $0.map(escape).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
        return Data([0xEF, 0xBB, 0xBF]) + Data(text.utf8)
    }

    static func escape(_ field: String) -> String {
        guard field.contains(where: { ",\"\r\n".contains($0) }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    static func fileName(now: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return "棚卸_\(formatter.string(from: now)).csv"
    }
}

struct CSVFile: Transferable {
    let data: Data
    let fileName: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { $0.data }
            .suggestedFileName { $0.fileName }
    }
}
