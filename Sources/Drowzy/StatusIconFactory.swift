import AppKit
import DrowzyCore

enum StatusIconFactory {
    static func menuBarImage(for mode: AwakeMode) -> NSImage {
        let symbolName: String

        switch mode {
        case .off:
            symbolName = "moon.fill"
        case .indefinite:
            symbolName = "sun.max.fill"
        case .timed:
            symbolName = "timer"
        }

        return symbolImage(named: symbolName) ?? fallbackImage(isActive: mode.isActive)
    }

    private static func symbolImage(named symbolName: String) -> NSImage? {
        guard let baseImage = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: "Drowzy"
        ) else {
            return nil
        }

        let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let image = baseImage.withSymbolConfiguration(configuration) ?? baseImage
        image.isTemplate = true
        return image
    }

    private static func fallbackImage(isActive: Bool) -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()

        let rect = NSRect(x: 4, y: 4, width: 10, height: 10)
        let path = NSBezierPath(ovalIn: rect)
        path.lineWidth = 2
        NSColor.labelColor.set()

        if isActive {
            path.fill()
        } else {
            path.stroke()
        }

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
