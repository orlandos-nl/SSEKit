## SSEKit

Support for Server-Sent Events in Swift through AsyncSequence<ByteBuffer>.

### Usage with Hummingbird 2

Hummingbird 2's ResponseBody is already conforming to `AsyncSequence<ByteBuffer>`, so you can use the APIs easily.
There's [Example Code](https://github.com/orlandos-nl/SSEKit/tree/main/Example) in this repository for Hummingbird 2.

```swift
import SSEKit
router.get("events") { req, context in
  // Get any `AsyncSequence<ServerSentEvent>`. We'll use AsyncStream to make it easy
  let (events, continuation) = AsyncStream<ServerSentEvent>.makeStream()

  // TODO: Emit events into `continuation` using your logic
  // This logic emits the current time as ISO8601
  let now = ISO8601DateFormatter().string(from: Date())
  continuation.yield(ServerSentEvent(data: SSEValue(string: now)))

  // Closing the stream is important, as omitting this will let the body hang indefinitely
  continuation.finish()

  let body = ResponseBody(asyncSequence: events.mapToByteBuffer(allocator: context.allocator))
  return Response(status: .ok, headers: [.contentType: "text/event-stream"], body: body)
}
```
