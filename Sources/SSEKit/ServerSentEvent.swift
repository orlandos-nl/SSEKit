import NIOCore

public struct ServerSentEvent: Equatable, Sendable {
    // defaults to `message`
    public var type: String?
    public var comment: SSEValue?
    public var data: SSEValue
    public var id: String?

    public init(
        type: String? = "message",
        comment: SSEValue? = nil,
        data: SSEValue,
        id: String? = nil
    ) {
        self.type = type
        self.comment = comment
        self.data = data
        self.id = id
    }

    internal func makeBuffer(allocator: ByteBufferAllocator) -> ByteBuffer {
        var string = ""

        if let type = type {
            string += "event: \(type)\n"
        }

        if let comment = comment {
            for part in comment.parts {
                string += ": \(part)\n"
            }
        }

        for part in data.parts {
            string += "data: \(part)\n"
        }

        if let id = id {
            string += "id: \(id)\n"
        }

        string.append("\n")

        return allocator.buffer(string: string)
    }
}
