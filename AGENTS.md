# myKit agent index

myKit is a SwiftPM library of design tokens, surfaces and standard UI parts shared by personal macOS 26 apps (Swift 6, SwiftUI + AppKit). It holds the parts that more than one app needs; an app-specific view stays in its app until a second app needs it.

`scripts/check.sh` is the gate: format, lint, build with warnings as errors, tests. CI runs the same script. Always `xcrun swift`.

This file is a map, not the docs. Open the page that owns the task:

- What each part is for: [README.md](./README.md)
- Traps and their fixes: [docs/gotchas.md](./docs/gotchas.md)
- Lint rules shared with the apps: [lint/swiftlint.yml](./lint/swiftlint.yml), [.swift-format](./.swift-format)

## Rules

- Token values (`Sources/MyKit/Tokens.swift`) and surfaces are design decisions. Change them only when asked, and say that every app's look changes.
- myKit views follow the same token rules as the apps. They never use an app's brand color: they use `.tint`, and every hosting root takes a `tint:` parameter.
- A change to `lint/` or `.swift-format` reaches an app only when the app moves to the new tag and runs `scripts/sync-lint-config.sh`.
- Bug fixes get a regression test where the logic allows. Do not test token values.
- New version: list changes under a new heading in [CHANGELOG.md](./CHANGELOG.md), tag `vX.Y.Z`.
