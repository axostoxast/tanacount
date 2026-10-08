import Foundation

/// JAN（EAN-13 / EAN-8）の正規化とチェックデジット検証
enum JAN {
    enum ValidationError: Error, Equatable {
        case notDigits
        case invalidLength(Int)
        case invalidCheckDigit(expected: Int)

        var message: String {
            switch self {
            case .notDigits:
                "JANコードは数字で入力してください"
            case .invalidLength(let count):
                "JANコードは8桁または13桁です（入力は\(count)桁）"
            case .invalidCheckDigit(let expected):
                "最後の1桁（チェックデジット）が合いません。正しくは \(expected) です。番号を確認してください"
            }
        }
    }

    /// 全角数字・空白・ハイフンを許容し、8桁・13桁でチェックデジットが正しければ返す。
    /// 12桁（UPC-A）は先頭に0を付けて13桁に揃える。
    static func validate(_ raw: String) -> Result<String, ValidationError> {
        let halfwidth = raw.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? raw
        let trimmed = halfwidth.filter { !$0.isWhitespace && $0 != "-" }
        guard !trimmed.isEmpty, trimmed.allSatisfy({ $0.isASCII && $0.isNumber }) else { return .failure(.notDigits) }
        let code = trimmed.count == 12 ? "0" + trimmed : trimmed
        guard code.count == 8 || code.count == 13 else { return .failure(.invalidLength(trimmed.count)) }
        let expected = checkDigit(for: code.dropLast())
        guard code.last?.wholeNumberValue == expected else { return .failure(.invalidCheckDigit(expected: expected)) }
        return .success(code)
    }

    static func normalize(_ raw: String) -> String? {
        try? validate(raw).get()
    }

    /// チェックデジットを除いた桁から計算する。左隣から右→左に重み3,1,3,1…
    static func checkDigit(for body: some StringProtocol) -> Int {
        let sum = body.compactMap(\.wholeNumberValue).reversed().enumerated()
            .reduce(0) { $0 + $1.element * ($1.offset.isMultiple(of: 2) ? 3 : 1) }
        return (10 - sum % 10) % 10
    }
}
