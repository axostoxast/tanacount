import Foundation
import Observation
import StoreKit

/// 買い切り「プロ版」（CSV書き出しを解放）の購入状態
@MainActor
@Observable
final class ProStore {
    static let productID = "com.sidebiz.tanacount.pro"

    private(set) var product: Product?
    private(set) var isPro = false
    private(set) var isPurchasing = false
    var errorMessage: String?

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result { await transaction.finish() }
                await self?.refreshEntitlements()
            }
        }
        Task { [weak self] in await self?.load() }
    }

    func load() async {
        do {
            product = try await Product.products(for: [Self.productID]).first
        } catch {
            errorMessage = "商品情報を取得できませんでした"
        }
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                entitled = true
            }
        }
        isPro = entitled
    }

    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await refreshEntitlements()
            case .success(.unverified):
                errorMessage = "購入を確認できませんでした"
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "購入に失敗しました"
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = "購入の復元に失敗しました"
        }
        await refreshEntitlements()
    }
}
