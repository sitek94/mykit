import AppKit
import Carbon.HIToolbox
import Observation
import os

/// A system-wide shortcut that the user can change in Settings (see `ShortcutRecorder`).
/// Uses Carbon hot keys, which need no extra permission. Each instance has its own id, so an app can have several.
@MainActor
@Observable
public final class GlobalShortcut {
    /// The current shortcut; nil when the user cleared it. Setting it stores it and registers it again.
    public var shortcut: Shortcut? {
        didSet {
            store()
            register()
        }
    }
    /// False when another app already owns the shortcut.
    public private(set) var isRegistered = false

    @ObservationIgnored private let defaultsKey: String
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let action: () -> Void
    @ObservationIgnored private let id: UInt32
    @ObservationIgnored private var hotKeyRef: EventHotKeyRef?
    @ObservationIgnored private var isSuspended = false

    /// - Parameters:
    ///   - name: the UserDefaults key for the stored shortcut.
    ///   - defaultShortcut: used until the user records or clears one.
    public init(name: String, default defaultShortcut: Shortcut?, defaults: UserDefaults = .standard, action: @escaping () -> Void) {
        defaultsKey = "shortcut." + name
        self.defaults = defaults
        self.action = action
        id = HotKeyCenter.add(action)
        if let data = defaults.data(forKey: defaultsKey) {
            shortcut = try? JSONDecoder().decode(Shortcut?.self, from: data)
        } else {
            shortcut = defaultShortcut
        }
        register()
    }

    isolated deinit {
        unregister()
        HotKeyCenter.remove(id)
    }

    /// While a recorder listens, the live hot key must not fire.
    func suspend() {
        isSuspended = true
        unregister()
    }

    func resume() {
        isSuspended = false
        register()
    }

    private func store() {
        if let data = try? JSONEncoder().encode(shortcut) {
            defaults.set(data, forKey: defaultsKey)
        }
    }

    private func register() {
        unregister()
        guard !isSuspended, let shortcut else {
            isRegistered = false
            return
        }
        hotKeyRef = HotKeyCenter.register(shortcut, id: id)
        isRegistered = hotKeyRef != nil
        if !isRegistered {
            Logger(subsystem: "dev.maciek.mykit", category: "shortcut")
                .error("could not register \(shortcut.displayText, privacy: .public); another app may own it")
        }
    }

    private func unregister() {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        hotKeyRef = nil
    }
}

/// One Carbon handler for the process; it reads the hot key id from the event and runs that shortcut's action.
@MainActor
private enum HotKeyCenter {
    static let signature = OSType(0x4D59_4B54)  // "MYKT"
    static var actions: [UInt32: () -> Void] = [:]
    static var nextID: UInt32 = 1
    static var handlerInstalled = false

    static func add(_ action: @escaping () -> Void) -> UInt32 {
        installHandler()
        let id = nextID
        nextID += 1
        actions[id] = action
        return id
    }

    static func remove(_ id: UInt32) {
        actions[id] = nil
    }

    static func register(_ shortcut: Shortcut, id: UInt32) -> EventHotKeyRef? {
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            shortcut.keyCode, shortcut.carbonModifiers, EventHotKeyID(signature: signature, id: id),
            GetApplicationEventTarget(), 0, &ref
        )
        return status == noErr ? ref : nil
    }

    private static func installHandler() {
        guard !handlerInstalled else { return }
        handlerInstalled = true
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ in
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil,
                    MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID
                )
                guard status == noErr, hotKeyID.signature == HotKeyCenter.signature else {
                    return OSStatus(eventNotHandledErr)
                }
                // Carbon delivers hot key events on the main thread.
                MainActor.assumeIsolated { HotKeyCenter.actions[hotKeyID.id]?() }
                return noErr
            },
            1, &spec, nil, nil
        )
    }
}
