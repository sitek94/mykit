import AppKit
import Carbon.HIToolbox

/// A key with modifiers. Codable so Settings can store it.
public struct Shortcut: Codable, Hashable, Sendable {
    public var keyCode: UInt32
    /// `NSEvent.ModifierFlags` raw value, limited to ⌃ ⌥ ⇧ ⌘.
    public var modifiers: UInt

    public static let relevantModifiers: NSEvent.ModifierFlags = [.control, .option, .shift, .command]
    public static let hyper: NSEvent.ModifierFlags = relevantModifiers

    public init(keyCode: Int, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = UInt32(keyCode)
        self.modifiers = modifiers.intersection(Self.relevantModifiers).rawValue
    }

    public var modifierFlags: NSEvent.ModifierFlags { NSEvent.ModifierFlags(rawValue: modifiers) }

    /// A global shortcut needs ⌃, ⌥ or ⌘; ⇧ alone would take a normal typed character.
    public var isValidGlobal: Bool {
        !modifierFlags.isDisjoint(with: [.control, .option, .command])
    }

    /// Keys in Apple order. All four modifiers show as ✦ (Hyper).
    public var keys: [String] {
        let flags = modifierFlags
        var keys: [String] = []
        if flags == Self.hyper {
            keys.append("✦")
        } else {
            if flags.contains(.control) { keys.append("⌃") }
            if flags.contains(.option) { keys.append("⌥") }
            if flags.contains(.shift) { keys.append("⇧") }
            if flags.contains(.command) { keys.append("⌘") }
        }
        keys.append(Self.keyName(for: Int(keyCode)))
        return keys
    }

    /// "✦V", "⇧⌘4": the form for UI text.
    public var displayText: String { keys.joined() }

    var carbonModifiers: UInt32 {
        let flags = modifierFlags
        var carbon = 0
        if flags.contains(.command) { carbon |= cmdKey }
        if flags.contains(.option) { carbon |= optionKey }
        if flags.contains(.control) { carbon |= controlKey }
        if flags.contains(.shift) { carbon |= shiftKey }
        return UInt32(carbon)
    }

    private static let namedKeys: [Int: String] = [
        kVK_Return: "Return", kVK_ANSI_KeypadEnter: "Enter", kVK_Escape: "Esc", kVK_Tab: "Tab", kVK_Space: "Space",
        kVK_Delete: "⌫", kVK_ForwardDelete: "⌦", kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑",
        kVK_DownArrow: "↓", kVK_Home: "Home", kVK_End: "End", kVK_PageUp: "Page Up", kVK_PageDown: "Page Down",
        kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5", kVK_F6: "F6",
        kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12",
    ]

    /// The key's name in the current keyboard layout, so a German layout shows Z where a US one shows Y.
    static func keyName(for keyCode: Int) -> String {
        if let name = namedKeys[keyCode] { return name }
        guard
            let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
            let pointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        else { return "#\(keyCode)" }
        let layoutData = Unmanaged<CFData>.fromOpaque(pointer).takeUnretainedValue() as Data
        var deadKeys: UInt32 = 0
        var length = 0
        var characters = [UniChar](repeating: 0, count: 4)
        let status = layoutData.withUnsafeBytes { bytes in
            UCKeyTranslate(
                bytes.baseAddress!.assumingMemoryBound(to: UCKeyboardLayout.self), UInt16(keyCode),
                UInt16(kUCKeyActionDisplay), 0, UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysBit),
                &deadKeys, characters.count, &length, &characters
            )
        }
        guard status == noErr, length > 0 else { return "#\(keyCode)" }
        return String(utf16CodeUnits: characters, count: length).uppercased()
    }
}
