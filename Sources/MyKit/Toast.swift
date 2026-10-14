import SwiftUI

/// A short confirmation such as "Copied".
public struct Toast: View {
    let text: String
    let systemImage: String

    public init(_ text: String, systemImage: String = "checkmark.circle.fill") {
        self.text = text
        self.systemImage = systemImage
    }

    public var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: systemImage).foregroundStyle(.success)
        }
        .font(.textBody.weight(.medium))
        .padding(.horizontal, .space3)
        .padding(.vertical, .space2)
        .capsuleSurface()
    }
}

extension View {
    /// Shows `text` as a toast at the top while it is not nil.
    public func toast(_ text: String?) -> some View {
        overlay(alignment: .top) {
            if let text {
                Toast(text)
                    .padding(.top, .space3)
                    .transition(.opacity)
            }
        }
        .animation(.standard, value: text)
    }
}
