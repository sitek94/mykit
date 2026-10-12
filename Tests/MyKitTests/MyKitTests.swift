import AppKit
import Carbon.HIToolbox
import SwiftUI
import Testing

@testable import MyKit

struct ShortcutTests {
    @Test func hyperShowsAsOneGlyph() {
        let shortcut = Shortcut(keyCode: kVK_Space, modifiers: [.command, .control, .option, .shift])
        #expect(shortcut.keys == ["✦", "Space"])
        #expect(shortcut.displayText == "✦Space")
    }

    @Test func modifiersFollowAppleOrder() {
        let shortcut = Shortcut(keyCode: kVK_Return, modifiers: [.command, .shift, .control])
        #expect(shortcut.keys == ["⌃", "⇧", "⌘", "Return"])
    }

    @Test func ignoresModifiersOutsideControlOptionShiftCommand() {
        let shortcut = Shortcut(keyCode: kVK_F1, modifiers: [.command, .capsLock, .function])
        #expect(shortcut.modifierFlags == .command)
    }

    @Test func menuShortcutKeepsTheKeyAndModifiers() {
        let shortcut = Shortcut(keyCode: kVK_ANSI_A, modifiers: [.control, .shift, .command]).menuShortcut
        #expect(shortcut?.key == KeyEquivalent("a"))
        #expect(shortcut?.modifiers == [.control, .shift, .command])
    }

    @Test func menuShortcutIsNilForANamedKey() {
        #expect(Shortcut(keyCode: kVK_Space, modifiers: .command).menuShortcut == nil)
    }

    @Test func globalShortcutNeedsControlOptionOrCommand() {
        #expect(!Shortcut(keyCode: kVK_F1, modifiers: []).isValidGlobal)
        #expect(!Shortcut(keyCode: kVK_F1, modifiers: .shift).isValidGlobal)
        #expect(Shortcut(keyCode: kVK_F1, modifiers: [.shift, .option]).isValidGlobal)
    }
}

final class GlobalShortcutTests {
    // One suite for all runs; a unique name per test, removed afterwards.
    let defaults = UserDefaults(suiteName: "MyKitTests")!
    let name = UUID().uuidString
    let f19 = Shortcut(keyCode: kVK_F19, modifiers: [.command, .option])

    isolated deinit {
        defaults.removeObject(forKey: "shortcut." + name)
    }

    @Test func usesTheDefaultUntilTheUserChangesIt() {
        let shortcut = GlobalShortcut(name: name, default: f19, defaults: defaults) {}
        #expect(shortcut.shortcut == f19)
    }

    @Test func aClearedShortcutStaysClearedAfterRestart() {
        GlobalShortcut(name: name, default: f19, defaults: defaults) {}.shortcut = nil
        let restarted = GlobalShortcut(name: name, default: f19, defaults: defaults) {}
        #expect(restarted.shortcut == nil)
    }

    @Test func aRecordedShortcutSurvivesRestart() {
        let recorded = Shortcut(keyCode: kVK_F18, modifiers: .control)
        GlobalShortcut(name: name, default: f19, defaults: defaults) {}.shortcut = recorded
        let restarted = GlobalShortcut(name: name, default: f19, defaults: defaults) {}
        #expect(restarted.shortcut == recorded)
    }
}

struct VersionLineTests {
    @Test func readsNameVersionBuildAndCommit() {
        let info: [String: Any] = [
            "CFBundleName": "myClips", "CFBundleShortVersionString": "0.2.0", "CFBundleVersion": "14", "GitCommit": "a1b2c3d",
        ]
        #expect(VersionLine.text(info: info) == "myClips 0.2.0 (14, a1b2c3d)")
    }

    @Test func marksADevelopmentBuild() {
        #expect(VersionLine.text(info: [:]) == "app dev (?, ?)")
    }
}

/// Compiles only if the tokens work in the places views use them.
struct TokenUsage: View {
    var body: some View {
        VStack(spacing: .space2) {
            Text("Title").font(.textTitle)
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.success)
        }
        .padding(.space4)
        .tint(.danger)
        .animation(.quick, value: 0)
    }
}
