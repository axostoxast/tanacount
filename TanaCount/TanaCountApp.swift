import SwiftData
import SwiftUI

@main
struct TanaCountApp: App {
    @State private var store = ProStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .modelContainer(for: Item.self)
    }
}
