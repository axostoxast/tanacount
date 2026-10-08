import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    /// 正規化済みのJAN（8桁または13桁）。未登録ならnil
    var janCode: String?
    var count: Int
    var createdAt: Date
    var updatedAt: Date

    init(name: String, janCode: String? = nil, count: Int = 0, now: Date = .now) {
        self.name = name
        self.janCode = janCode
        self.count = count
        self.createdAt = now
        self.updatedAt = now
    }

    func adjust(by delta: Int, now: Date = .now) {
        count = max(0, count + delta)
        updatedAt = now
    }
}
