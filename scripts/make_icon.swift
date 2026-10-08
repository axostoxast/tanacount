// アプリアイコン（1024x1024）を生成する: swift scripts/make_icon.swift <出力PNG>
import AppKit

let size = 1024.0
let output = CommandLine.arguments.dropFirst().first ?? "AppIcon.png"
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size), bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let rect = NSRect(x: 0, y: 0, width: size, height: size)
NSGradient(starting: NSColor(red: 0.10, green: 0.55, blue: 0.95, alpha: 1),
           ending: NSColor(red: 0.02, green: 0.30, blue: 0.70, alpha: 1))!.draw(in: rect, angle: -90)

let config = NSImage.SymbolConfiguration(pointSize: 560, weight: .medium)
    .applying(.init(paletteColors: [.white]))
let symbol = NSImage(systemSymbolName: "barcode.viewfinder", accessibilityDescription: nil)!.withSymbolConfiguration(config)!
let symbolSize = symbol.size
symbol.draw(in: NSRect(x: (size - symbolSize.width) / 2, y: (size - symbolSize.height) / 2,
                       width: symbolSize.width, height: symbolSize.height))

NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output))
