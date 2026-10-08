import SwiftData
import SwiftUI

@main
struct TanaCountApp: App {
    @State private var store = ProStore()
    private let container: ModelContainer = {
        #if DEBUG
        if ScreenshotMode.current != nil { return ScreenshotMode.makeContainer() }
        #endif
        return try! ModelContainer(for: Item.self)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .modelContainer(container)
    }
}
