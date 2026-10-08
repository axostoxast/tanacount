import Foundation
import Testing
@testable import TanaCount

struct JANTests {
    @Test(arguments: ["4901234567894", "49012347", " 4901234567894 "])
    func acceptsValidCodes(_ raw: String) {
        #expect(JAN.normalize(raw) == raw.trimmingCharacters(in: .whitespaces))
    }

    @Test(arguments: ["4901234567890", "49012340", "490123456789", "abc", ""])
    func rejectsInvalidCodes(_ raw: String) {
        #expect(JAN.normalize(raw) == nil)
    }

    @Test(arguments: ["４９０１２３４５６７８９４", "49-0123-4567-894", "4901 2345 67894"])
    func acceptsFullwidthAndSeparators(_ raw: String) {
        #expect(JAN.normalize(raw) == "4901234567894")
    }

    @Test func reportsWhyValidationFailed() {
        #expect(JAN.validate("4901234567890") == .failure(.invalidCheckDigit(expected: 4)))
        #expect(JAN.validate("49012345678") == .failure(.invalidLength(11)))
        #expect(JAN.validate("49O1234567894") == .failure(.notDigits))
    }

    @Test func padsUPCAToThirteenDigits() {
        #expect(JAN.normalize("036000291452") == "0036000291452")
    }
}

struct CSVExporterTests {
    @Test func startsWithBOMAndUsesCRLF() throws {
        let data = CSVExporter.makeData(rows: [])
        #expect(Array(data.prefix(3)) == [0xEF, 0xBB, 0xBF])
        let text = try #require(String(data: data.dropFirst(3), encoding: .utf8))
        #expect(text == "JANコード,品名,数量,最終更新\r\n")
    }

    @Test func escapesFieldsAndLeavesMissingJANEmpty() throws {
        let date = try #require(ISO8601DateFormatter().date(from: "2026-10-07T03:04:00Z"))
        let rows = [CSVRow(name: "ペン, \"黒\"", janCode: nil, count: 3, updatedAt: date)]
        let text = try #require(String(data: CSVExporter.makeData(rows: rows).dropFirst(3), encoding: .utf8))
        let line = text.components(separatedBy: "\r\n")[1]
        #expect(line.hasPrefix(",\"ペン, \"\"黒\"\"\",3,2026/10/07 "))
    }
}

struct ItemTests {
    @Test func countNeverGoesNegative() {
        let item = Item(name: "テスト", count: 1)
        item.adjust(by: -5)
        #expect(item.count == 0)
    }
}
