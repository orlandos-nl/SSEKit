import NIOCore

extension AsyncSequence where Element == ServerSentEvent {
    @available(macOS 15, iOS 18, watchOS 11, tvOS 18, *)
    public func mapToByteBuffer(allocator: ByteBufferAllocator) -> some AsyncSequence<ByteBuffer, Failure> {
        map { event in
            event.makeBuffer(allocator: allocator)
        }
    }

    @_disfavoredOverload
    public func mapToByteBuffer(allocator: ByteBufferAllocator) -> AsyncThrowingStream<ByteBuffer, Error> {
        var iterator = self.makeAsyncIterator()
        return AsyncThrowingStream {
            guard let event = try await iterator.next() else {
                return nil
            }

            return event.makeBuffer(allocator: allocator)
        }
    }
}
