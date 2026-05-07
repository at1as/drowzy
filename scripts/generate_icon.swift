#!/usr/bin/env swift

import AppKit
import Foundation

let outputPath = CommandLine.arguments.dropFirst().first ?? ".build/Drowzy.iconset"
let outputURL = URL(fileURLWithPath: outputPath)
let fileManager = FileManager.default

try? fileManager.removeItem(at: outputURL)
try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)

let baseSizes = [16, 32, 128, 256, 512]

for baseSize in baseSizes {
    try writeIcon(size: baseSize, scale: 1, to: outputURL)
    try writeIcon(size: baseSize, scale: 2, to: outputURL)
}

func writeIcon(size: Int, scale: Int, to directory: URL) throws {
    let pixels = size * scale
    let image = drawIcon(size: pixels)
    let suffix = scale == 1 ? "" : "@\(scale)x"
    let fileName = "icon_\(size)x\(size)\(suffix).png"
    let fileURL = directory.appendingPathComponent(fileName)

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw CocoaError(.fileWriteUnknown)
    }

    try pngData.write(to: fileURL)
}

func drawIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = CGFloat(size) * 0.22
    let backgroundPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundPath.addClip()

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.05, green: 0.10, blue: 0.15, alpha: 1),
        NSColor(calibratedRed: 0.05, green: 0.23, blue: 0.29, alpha: 1)
    ])
    gradient?.draw(in: bounds, angle: 90)

    let moonRect = NSRect(
        x: CGFloat(size) * 0.22,
        y: CGFloat(size) * 0.28,
        width: CGFloat(size) * 0.48,
        height: CGFloat(size) * 0.48
    )
    NSColor(calibratedRed: 1.00, green: 0.85, blue: 0.36, alpha: 1).setFill()
    NSBezierPath(ovalIn: moonRect).fill()

    let cutoutRect = moonRect.offsetBy(dx: CGFloat(size) * 0.15, dy: CGFloat(size) * 0.08)
    NSColor(calibratedRed: 0.05, green: 0.18, blue: 0.24, alpha: 1).setFill()
    NSBezierPath(ovalIn: cutoutRect).fill()

    let clockRadius = CGFloat(size) * 0.18
    let clockCenter = NSPoint(x: CGFloat(size) * 0.68, y: CGFloat(size) * 0.32)
    let clockRect = NSRect(
        x: clockCenter.x - clockRadius,
        y: clockCenter.y - clockRadius,
        width: clockRadius * 2,
        height: clockRadius * 2
    )

    NSColor(calibratedRed: 0.58, green: 0.95, blue: 0.82, alpha: 1).setFill()
    NSBezierPath(ovalIn: clockRect).fill()

    NSColor(calibratedRed: 0.05, green: 0.16, blue: 0.20, alpha: 1).setStroke()
    let handPath = NSBezierPath()
    handPath.lineWidth = max(2, CGFloat(size) * 0.022)
    handPath.lineCapStyle = .round
    handPath.move(to: clockCenter)
    handPath.line(to: NSPoint(x: clockCenter.x, y: clockCenter.y + clockRadius * 0.52))
    handPath.move(to: clockCenter)
    handPath.line(to: NSPoint(x: clockCenter.x + clockRadius * 0.45, y: clockCenter.y))
    handPath.stroke()

    image.unlockFocus()
    return image
}
