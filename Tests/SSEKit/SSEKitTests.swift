@testable import SSEKit
import NIOCore
import XCTest

final class SSEKitTests: XCTestCase {
    func testSSESerialization() throws {
        let event = ServerSentEvent(data: SSEValue(string: "hello\nworld"))
        var serialized = event.makeBuffer(allocator: ByteBufferAllocator())
        XCTAssertEqual(String(buffer: serialized), """
        event: message
        data: hello
        data: world


        """)

        var parser = SSEParser()
        let parsedEvents = try parser.process(sse: &serialized)
        XCTAssertEqual(parsedEvents, [event])
    }

    func testSSESinglePassMultipleMessagesParsing() throws {
        var serialized = ByteBuffer(string: """
        event: message
        data: 1
        data: 2

        event: message
        data: 3
        data: 4


        """)

        var parser = SSEParser()
        let parsedEvents = try parser.process(sse: &serialized)
        XCTAssertEqual(parsedEvents, [
            ServerSentEvent(data: "1\n2"),
            ServerSentEvent(data: "3\n4")
        ])
    }

    func testSSESegmentedParsing() async throws {
        let parts = [
            """
            event: message
            data: 1

            """,
            """
            data: 2

            event: message
            """,
            """

            data: 3
            data: 4



            """
        ]

        var iterator = parts.makeIterator()

        let serialized = AsyncStream<ByteBuffer> {
            guard let event = iterator.next() else {
                return nil
            }

            return ByteBuffer(string: event)
        }

        let parsedEvents = serialized.getServerSentEvents(allocator: ByteBufferAllocator())
        var events = [ServerSentEvent]()

        for try await event in parsedEvents {
            events.append(event)
        }

        XCTAssertEqual(events, [
            ServerSentEvent(data: "1\n2"),
            ServerSentEvent(data: "3\n4")
        ])
    }

    func testEndToEndUse() async throws {
        let allEvents = ["hello\nworld", "1", "2", "3"]
        var iterator = allEvents.makeIterator()

        let producedEvents = AsyncStream<ServerSentEvent> {
            guard let event = iterator.next() else {
                return nil
            }

            return ServerSentEvent(data: SSEValue(string: event))
        }

        let serialized = producedEvents.mapToByteBuffer(allocator: ByteBufferAllocator())
        let parsedEvents = serialized.getServerSentEvents(allocator: ByteBufferAllocator())
        var events = [ServerSentEvent]()

        for try await event in parsedEvents {
            events.append(event)
        }

        let expectedEvents = allEvents.map { event in
            // 'message' is the default
            ServerSentEvent(type: "message", data: SSEValue(string: event))
        }

        XCTAssertEqual(events, expectedEvents)
    }
}
