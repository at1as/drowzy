import AppKit
import DrowzyCore

enum StatusIconFactory {
    static func menuBarImage(for mode: AwakeMode) -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()

        drawMoon()

        switch mode {
        case .off:
            drawSleepBadge()
        case .indefinite:
            drawInfinityBadge()
        case .timed:
            drawClockBadge()
        }

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private static func drawMoon() {
        let moonRect = NSRect(x: 0.8, y: 3.2, width: 9.4, height: 11.5)
        let cutoutRect = moonRect.offsetBy(dx: 3.1, dy: 1.35)

        NSGraphicsContext.current?.compositingOperation = .sourceOver
        NSColor.labelColor.set()
        NSBezierPath(ovalIn: moonRect).fill()

        NSGraphicsContext.current?.compositingOperation = .clear
        NSBezierPath(ovalIn: cutoutRect).fill()
        NSGraphicsContext.current?.compositingOperation = .sourceOver
    }

    private static func drawSleepBadge() {
        drawSymbol("Zzz", in: NSRect(x: 8.2, y: 3.6, width: 9.8, height: 8.2), fontSize: 7.8, weight: .bold)
    }

    private static func drawInfinityBadge() {
        drawSymbol("∞", in: NSRect(x: 8.6, y: 3.15, width: 9.2, height: 9.4), fontSize: 10.6, weight: .bold)
    }

    private static func drawClockBadge() {
        let clockRect = NSRect(x: 8.15, y: 1.6, width: 8.55, height: 8.55)
        let center = NSPoint(x: clockRect.midX, y: clockRect.midY)
        let radius = clockRect.width / 2

        NSColor.labelColor.set()
        NSBezierPath(ovalIn: clockRect).fill()

        NSGraphicsContext.current?.compositingOperation = .clear
        drawHands(center: center, radius: radius, lineWidth: 1.05)
        NSGraphicsContext.current?.compositingOperation = .sourceOver
    }

    private static func drawHands(center: NSPoint, radius: CGFloat, lineWidth: CGFloat) {
        let hands = NSBezierPath()
        hands.lineWidth = lineWidth
        hands.lineCapStyle = .round
        hands.move(to: center)
        hands.line(to: NSPoint(x: center.x, y: center.y + radius * 0.48))
        hands.move(to: center)
        hands.line(to: NSPoint(x: center.x + radius * 0.42, y: center.y))

        NSColor.labelColor.setStroke()
        hands.stroke()
    }

    private static func drawSymbol(
        _ symbol: String,
        in rect: NSRect,
        fontSize: CGFloat,
        weight: NSFont.Weight
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: weight),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]

        symbol.draw(in: rect, withAttributes: attributes)
    }
}
