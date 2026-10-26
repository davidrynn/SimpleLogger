// Renders the app icon: a flat tally cap above a count window reading "0001", on the accent blue. The
// colors and gradients are copied from `TallyCap` and `CountWindow` (Shared/Tally/) so the icon matches the app.
//
// Regenerate both icon sets (every file is resized from the 1024 px render, which has no alpha):
//   swift scripts/render_app_icon.swift /tmp/ios.png
//   swift scripts/render_app_icon.swift /tmp/watch.png watch    # smaller parts, clear of the round mask
//   for f in SimplerLogger/Assets.xcassets/AppIcon.appiconset/*.png; do
//     px=$(sips -g pixelWidth "$f" | awk '/pixelWidth/{print $2}'); sips -z $px $px /tmp/ios.png --out "$f"
//   done   # and the same for SimplerLoggerWatch with /tmp/watch.png
import SwiftUI
import AppKit

extension Color {
    init(rgb: UInt32) {
        self.init(red: Double((rgb >> 16) & 0xFF) / 255, green: Double((rgb >> 8) & 0xFF) / 255, blue: Double(rgb & 0xFF) / 255)
    }
}

struct Icon: View {
    let side: CGFloat = 1024
    let watch: Bool

    var cap: some View {
        let d: CGFloat = watch ? 330 : 390
        let stops: [(UInt32, CGFloat)] = [(0xE6E8EB, 0), (0xE1E4E7, 0.62), (0xEEF0F2, 0.72), (0xC3C7CB, 0.85), (0x9DA1A7, 0.95), (0x8C9096, 1)]
        return Circle()
            .fill(RadialGradient(stops: stops.map { .init(color: Color(rgb: $0.0), location: $0.1) },
                                 center: .center, startRadius: 0, endRadius: d / 2))
            .overlay(Circle().strokeBorder(Color(rgb: 0x5F6368).opacity(0.6), lineWidth: 4))
            .overlay(Image(systemName: "plus").font(.system(size: d * 0.42, weight: .bold)).foregroundStyle(Color(rgb: 0x2B2D30)))
            .shadow(color: .black.opacity(0.28), radius: 22, y: 10)
            .frame(width: d, height: d)
    }

    var window: some View {
        let w: CGFloat = watch ? 96 : 122, h: CGFloat = watch ? 150 : 192, gap: CGFloat = 10
        let drum = LinearGradient(stops: [
            .init(color: Color(rgb: 0x050506), location: 0), .init(color: Color(rgb: 0x2A2A2E), location: 0.28),
            .init(color: Color(rgb: 0x3B3B40), location: 0.5), .init(color: Color(rgb: 0x2A2A2E), location: 0.72),
            .init(color: Color(rgb: 0x050506), location: 1),
        ], startPoint: .top, endPoint: .bottom)
        return HStack(spacing: gap) {
            ForEach(Array("0001".enumerated()), id: \.offset) { _, c in
                Text(String(c))
                    .font(.system(size: h * 0.75, weight: .semibold).width(.condensed))
                    .foregroundStyle(Color(rgb: 0xF4F4F2))
                    .frame(width: w, height: h)
                    .background(RoundedRectangle(cornerRadius: 8).fill(drum))
            }
        }
        .padding(gap + 4)
        .background(Color(rgb: 0x0D0D0F), in: .rect(cornerRadius: 26))
        .padding(14)
        .background(Color(rgb: 0xC3C6CA), in: .rect(cornerRadius: 36))
        .overlay(RoundedRectangle(cornerRadius: 36).strokeBorder(Color(rgb: 0x7B7F85), lineWidth: 4))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(rgb: 0x2E96FF), Color(rgb: 0x0A6FE0)], startPoint: .top, endPoint: .bottom)
            VStack(spacing: watch ? 36 : 52) {
                cap
                window
            }
            .offset(y: watch ? 0 : 6)
        }
        .frame(width: side, height: side)
        .environment(\.colorScheme, .light)
    }
}

@MainActor func render() {
    let args = CommandLine.arguments
    let renderer = ImageRenderer(content: Icon(watch: args.count > 2 && args[2] == "watch"))
    renderer.scale = 1
    guard let cg = renderer.cgImage else { fatalError("render failed") }
    // Redraw into an opaque RGB context: App Store icons must have no alpha channel.
    let ctx = CGContext(data: nil, width: cg.width, height: cg.height, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[1]))
}

MainActor.assumeIsolated { render() }
