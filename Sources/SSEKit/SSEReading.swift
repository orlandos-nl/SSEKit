import NIOCore

public struct SSEStream: AsyncSequence {
    public typealias Element = ServerSentEvent
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = ServerSentEvent
        private var bufferedEvents = [ServerSentEvent]()
        private var text: ByteBuffer
        private var parser = SSEParser()
        let produce: () async throws -> ByteBuffer?

        init(
            allocator: ByteBufferAllocator,
            produce: @escaping () async throws -> ByteBuffer?
        ) {
            self.text = allocator.buffer(capacity: 1024)
            self.produce = produce
        }

        private mutating func _next() async throws -> ServerSentEvent? {
            while bufferedEvents.isEmpty {
                guard var buffer = try await produce() else {
                    return nil
                }

                text.writeBuffer(&buffer)
                try bufferedEvents.append(contentsOf: parser.process(sse: &text))
                text.discardReadBytes()
            }

            if bufferedEvents.isEmpty {
                return nil
            }

            return bufferedEvents.removeFirst()
        }

        #if compiler(>=6.0)
        public mutating func next(
            isolation actor: isolated (any Actor)? = #isolation
        ) async throws -> ServerSentEvent? {
            try await _next()
        }
        #endif

        public mutating func next() async throws -> ServerSentEvent? {
            try await _next()
        }
    }

    private let iterator: AsyncIterator

    @_disfavoredOverload
    internal init<Sequence: AsyncSequence>(
        sequence: Sequence,
        allocator: ByteBufferAllocator
    ) where Sequence.Element == ByteBuffer {
        var iterator = sequence.makeAsyncIterator()
        self.iterator = AsyncIterator(allocator: allocator) {
            try await iterator.next()
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        iterator
    }
}

extension AsyncSequence where Element == ByteBuffer {
    public func getServerSentEvents(allocator: ByteBufferAllocator) -> SSEStream {
        SSEStream(sequence: self, allocator: allocator)
    }
}
