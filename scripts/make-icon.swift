// Writes an app icon as an Icon Composer document (.icon): a vertical gradient fill and one glass layer with the
// app's glyph. macOS 26 renders .icon icons natively; old .icns icons get shrunk into a gray frame. bundle.sh
// compiles the document with actool.
// The glyph is the app's own drawing (a 1024 × 1024 PNG on a transparent background): the SF Symbols license does
// not allow symbols in app icons.
// usage: xcrun swift scripts/make-icon.swift <out.icon> <top hex> <bottom hex> <glyph.png>
import Foundation

let args = CommandLine.arguments
guard args.count == 5 else {
    print("usage: make-icon.swift <out.icon> <top hex> <bottom hex> <glyph.png>")
    exit(2)
}

func components(_ hex: String) -> String {
    let value = UInt32(hex, radix: 16) ?? 0
    let parts = [value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF].map { String(format: "%.5f", Double($0) / 255) }
    return "srgb:" + parts.joined(separator: ",") + ",1.00000"
}

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
        {
          "glass" : true,
          "image-name" : "glyph.png",
          "name" : "glyph"
        }
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
try FileManager.default.copyItem(at: URL(filePath: args[4]), to: assets.appending(path: "glyph.png"))
try iconJSON.write(to: out.appending(path: "icon.json"), atomically: true, encoding: .utf8)
print("wrote \(out.path)")
