// Writes an app icon as an Icon Composer document (.icon): a vertical gradient fill and one glass layer with the
// app's glyph. macOS 26 renders .icon icons natively; old .icns icons get shrunk into a gray frame. bundle.sh
// compiles the document with actool.
// The glyph is the app's own drawing (a 1024 × 1024 PNG on a transparent background): the SF Symbols license does
// not allow symbols in app icons.
// Several glyph PNGs become separate layers, front first (for example a camera in front of viewfinder brackets):
// macOS gives each layer its own glass and depth.
// usage: xcrun swift scripts/make-icon.swift <out.icon> <top hex> <bottom hex> <glyph.png>...
import Foundation

let args = CommandLine.arguments
guard args.count >= 5 else {
    print("usage: make-icon.swift <out.icon> <top hex> <bottom hex> <glyph.png>...")
    exit(2)
}

func components(_ hex: String) -> String {
    let value = UInt32(hex, radix: 16) ?? 0
    let parts = [value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF].map { String(format: "%.5f", Double($0) / 255) }
    return "srgb:" + parts.joined(separator: ",") + ",1.00000"
}

let glyphs = Array(args[4...])
// Each layer is named after its file: glyph.png → "glyph".
let names = glyphs.map { URL(filePath: $0).deletingPathExtension().lastPathComponent }
let layers = names.map { "        {\n          \"glass\" : true,\n          \"image-name\" : \"\($0).png\",\n          \"name\" : \"\($0)\"\n        }" }
let iconJSON = """
{
  "fill" : {
    "linear-gradient" : [
      "\(components(args[2]))",
      "\(components(args[3]))"
    ]
  },
  "groups" : [
    {
      "layers" : [
\(layers.joined(separator: ",\n"))
      ],
      "shadow" : {
        "kind" : "neutral",
        "opacity" : 0.5
      },
      "translucency" : {
        "enabled" : true,
        "value" : 0.4
      }
    }
  ],
  "supported-platforms" : {
    "squares" : [
      "macOS"
    ]
  }
}

"""

let out = URL(filePath: args[1])
let assets = out.appending(path: "Assets")
try? FileManager.default.removeItem(at: out)
try FileManager.default.createDirectory(at: assets, withIntermediateDirectories: true)
for (glyph, name) in zip(glyphs, names) {
    try FileManager.default.copyItem(at: URL(filePath: glyph), to: assets.appending(path: "\(name).png"))
}
try iconJSON.write(to: out.appending(path: "icon.json"), atomically: true, encoding: .utf8)
print("wrote \(out.path)")
