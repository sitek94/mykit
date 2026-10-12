import SwiftUI

/// Key caps for hints in custom UI: `KeyCap("⇧", "Return")`. Menus show shortcuts by themselves.
public struct KeyCap: View {
    let keys: [String]

    public init(_ keys: String...) {
        self.keys = keys
    }

    public init(_ shortcut: Shortcut) {
        keys = shortcut.keys
    }

    public var body: some View {
        HStack(spacing: .space1) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Text(key)
                    .font(.textCaption.weight(.medium))
                    .padding(.horizontal, .space1)
                    .background(.quaternary, in: .rect(cornerRadius: .radiusSmall))
            }
        }
        .accessibilityElement(children: .combine)
    }
}
