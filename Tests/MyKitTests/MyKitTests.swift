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

    @Test func menuShortcutKeepsTheKeyAndModifiers() throws {
        let global = Shortcut(keyCode: kVK_ANSI_A, modifiers: [.control, .shift, .command])
        // The letter depends on the keyboard layout (A on US, Q on AZERTY).
        let letter = try #require(global.keys.last?.lowercased().first)
        #expect(global.menuShortcut?.key == KeyEquivalent(letter))
        #expect(global.menuShortcut?.modifiers == [.control, .shift, .command])
    }

    @Test func menuShortcutShowsNamedKeys() {
        #expect(Shortcut(keyCode: kVK_Space, modifiers: .command).menuShortcut?.key == .space)
        #expect(Shortcut(keyCode: kVK_LeftArrow, modifiers: .command).menuShortcut?.key == .leftArrow)
        #expect(Shortcut(keyCode: kVK_Delete, modifiers: .command).menuShortcut?.key == .delete)
        #expect(Shortcut(keyCode: kVK_F1, modifiers: .command).menuShortcut == nil)
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

struct StripPanelFrameTests {
    // A 1440 pt tall screen with a 33 pt menu bar and a 70 pt Dock at the bottom.
    let screen = CGRect(x: 0, y: 0, width: 2560, height: 1440)
    let visible = CGRect(x: 0, y: 70, width: 2560, height: 1337)

    @Test func bottomSheetSpansTheScreenOnItsEdgeOverTheDock() {
        let frame = StripPanel.frame(edge: .bottom, placement: .sheet, height: 300, screen: screen, visible: visible)
        #expect(frame == CGRect(x: 0, y: 0, width: 2560, height: 300))
    }

    @Test func topSheetSitsUnderTheMenuBar() {
        let frame = StripPanel.frame(edge: .top, placement: .sheet, height: 300, screen: screen, visible: visible)
        #expect(frame == CGRect(x: 0, y: 1107, width: 2560, height: 300))
    }

    @Test func insetBottomStripStaysAboveTheDock() {
        let frame = StripPanel.frame(edge: .bottom, placement: .inset, height: 240, screen: screen, visible: visible)
        #expect(frame == CGRect(x: 40, y: 110, width: 2480, height: 240))
    }
}

struct DragSourceTests {
    @Test func largePicturesShrinkToTheLimitKeepingTheirShape() {
        #expect(DragSource.fitted(CGSize(width: 960, height: 480)) == CGSize(width: 240, height: 120))
        #expect(DragSource.fitted(CGSize(width: 90, height: 600)) == CGSize(width: 36, height: 240))
    }

    @Test func aPointNearTheWindowBottomIsNearTheContentBottom() {
        #expect(DragSource.topLeft(CGPoint(x: 10, y: 5), height: 240) == CGPoint(x: 10, y: 235))
    }

    @Test func smallPicturesKeepTheirSize() {
        #expect(DragSource.fitted(CGSize(width: 64, height: 64)) == CGSize(width: 64, height: 64))
    }
}
