# Gotchas

Traps hit while building macOS 26 apps with SwiftPM and SwiftUI + AppKit: symptom → cause → fix. Most of the fixes are in myKit; the part that does it is named.

## Build and icon

- **`swift build` rejects the manifest (tools version 6.2, `defaultIsolation`).** A `swift` from another toolchain manager (for example swiftly) shadows Xcode's on `PATH`. Use `xcrun swift …`.
- **The app icon shows small, inside a gray frame.** macOS 26 does that to plain `.icns` icons. Use an Icon Composer `.icon` document (`scripts/make-icon.swift`), compile it with `xcrun actool … --app-icon AppIcon` in the bundle step, and set `CFBundleIconName`.
- **`actool` fails: "The output directory … does not exist", with a path in another repo.** It runs in a long-lived service that resolves relative paths against an earlier caller's folder. Pass absolute paths (`"$PWD/…"`).
- **`ImageRenderer` in a Swift script does not compile.** It is main-actor isolated. Wrap the script's top level in `MainActor.assumeIsolated`.
- **`open` fails with error -600 right after `pkill`.** The old process has not exited yet. Wait until `pgrep` is empty before you launch again.
- **An app without an Xcode project.** Build with `xcrun swift build -c release`, put the binary and an `Info.plist` into an `.app` in a `scripts/bundle.sh`, and sign it with an "Apple Development" identity.

## Permissions

- **Permissions reset after a rebuild.** Accessibility, Screen Recording and "Paste from Other Apps" grants belong to the bundle id and the signing identity. Sign with a stable identity; ad-hoc signatures need a new grant after each build. A new bundle id also needs new grants.
- **A command-line tool gets the terminal's permissions.** macOS checks a tool started from a terminal against the terminal's grants. Wrap the tool in a signed `.app` and start it with `open`.
- **Clipboard reads show a system alert (macOS 15.4+).** The app appears in Privacy & Security → Paste from Other Apps only after the first alert; set it to Always Allow. `NSPasteboard.accessBehavior` tells the state. `PermissionRow` + `SystemSettingsPane.pasteFromOtherApps` show it in Settings.

## Focus and windows

- **A panel shows, but typing goes to the app behind it.** A borderless `.nonactivatingPanel` does not reliably become key. Use `[.nonactivatingPanel, .titled, .fullSizeContentView]`, hide the title bar, and return `true` from `canBecomeKey` (`FloatingPanel`).
- **A panel closes at the wrong time.** Close it on explicit events (Esc, the hotkey, a click outside, another app becoming active), not on `resignKey`. Ignore clicks while `screencaptureui` is on screen (`FloatingPanel.Options`).
- **`NSApp.activate()` does nothing.** macOS 26 activation is cooperative: a background app cannot take focus from the active one. A Settings window opened from the menu bar flashes, then goes behind the active app. Show app windows with `AppWindows.show`: it waits for the status menu to close, makes the app a regular one while the window is open (Dock icon, ⌘ Tab), and activates with the deprecated forced call. Before an alert, a save or open panel, or Quick Look, call `AppWindows.activate()`.
- **Every single click feels slow.** `.onTapGesture(count: 2)` next to a single-tap gesture holds each click for the double-click interval. Use one tap handler and read `NSApp.currentEvent?.clickCount`.
- **A text field does not take focus.** Two `@FocusState`s in one window fight over the first responder; use one enum state. A focus state can also keep its old value from the last time the panel showed: set it to `nil`, then to the field.
- **The app quits right after launch, with no crash report.** Its menu bar icon is hidden (System Settings → Menu Bar), and a SwiftUI app whose only scene is a `MenuBarExtra` quits when that item goes away. Pass an `isInserted:` binding (`MenuBarItem`).
- **A hosted view ignores the app's tint.** An `NSHostingView` in a panel or window does not inherit the tint of the App scene. Set it at the hosting root (`FloatingPanel.setContent(tint:)`, `SettingsWindow(tint:)`).

## Global shortcuts

- **The wrong action runs when an app has two hotkeys.** A Carbon handler that does not read the hot key id runs one action for every hotkey. Read `kEventParamDirectObject` and dispatch by id (`GlobalShortcut`).
- **Pressing the current shortcut in the recorder runs the action.** The live hotkey must be unregistered while the recorder listens (`ShortcutRecorder`).
- **System menus show `⌃⌥⇧⌘V`, not `✦V`.** Menus draw `.keyboardShortcut` glyphs themselves. Show ✦ only in your own UI (`Shortcut.displayText`, `KeyCap`), and make menu items read the stored shortcut.

## Synthetic input

- **Synthetic keys arrive with modifiers held.** Events from a `.hidSystemState` source inherit the modifier state. Set `flags` on every event.
- **A pasted `⌘ V` types the wrong letter on another layout.** Find the key code for "v" in the current layout with `UCKeyTranslate`.

## UI testing

- **Testing the real app on a Mac someone is using.** A separate signed driver app (`my<App>Driver`) holds Screen Recording and Accessibility, runs as one long-lived process fed by a command queue, and accepts fixed verbs only.
- **Safe mode.** Keys and clicks go to the app only (`CGEvent.postToPid`); screenshots capture the app's windows only (ScreenCaptureKit); synthetic data comes from a scratch data directory; capture is paused; test hooks sit behind a launch flag. System-wide events only with the user's go-ahead and hands off the Mac.
- **Posted clicks do not reach SwiftUI buttons.** Cover clicks in a hands-off end-to-end run.
