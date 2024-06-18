public struct SSEValue: ExpressibleByStringLiteral, Equatable, Sendable {
    internal var parts = [Substring]()

    public var string: String {
        get {
            parts.joined(separator: "\n")
        }
        set {
            assert({
                !newValue.contains("\n") && !newValue.contains("\r")
            }())

            parts = newValue.split(omittingEmptySubsequences: true) { character in
                character == "\r" || character == "\n"
            }
        }
    }

    public init(string: String) {
        parts = string.split(omittingEmptySubsequences: true) { character in
            character == "\r" || character == "\n"
        }
    }

    public init(stringLiteral value: String) {
        self.init(string: value)
    }

    package init(unchecked parts: [String]) {
        self.parts = parts.map {
            Substring($0)
        }
    }
}
