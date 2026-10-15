import AppKit
import MyKit
import SwiftUI

// Draws every icon of the library on its tile, with its name, in dark and light, at 2x: the review sheet.
let out = CommandLine.arguments.dropFirst().first ?? "icons.png"

struct Sheet: View {
    let scheme: ColorScheme

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(130), alignment: .leading), count: 4), spacing: .space3) {
            ForEach(Icon.library, id: \.name) { entry in
                HStack(spacing: .space2) {
                    IconTile(entry.icon)
                    Text(entry.name).font(.textBody)
                }
            }
        }
        .padding(.space4)
        .background(.background)
        .environment(\.colorScheme, scheme)
    }
}

let renderer = ImageRenderer(
    content: VStack(spacing: 0) {
        Sheet(scheme: .dark)
        Sheet(scheme: .light)
    })
renderer.scale = 2
guard let image = renderer.nsImage, let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else { fatalError("render failed") }
try png.write(to: URL(filePath: out))
print("wrote \(out)")
