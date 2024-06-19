import NIOCore

extension AsyncSequence where Element == ServerSentEvent {
    public func mapToByteBuffer(
        allocator: ByteBufferAllocator
    ) -> AsyncMapSequence<Self, ByteBuffer> {
        map { event in
            event.makeBuffer(allocator: allocator)
        }
    }
}
