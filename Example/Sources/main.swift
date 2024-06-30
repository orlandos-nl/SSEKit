import SSEKit
import Hummingbird
import Foundation

let router = Router()
router.get { req, context in
    let html = """
    <html>
        <head>
            <script>
                const evtSource = new EventSource("//localhost:8080/events", {
                    withCredentials: true,
                });
                evtSource.onmessage = (event) => {
                const newElement = document.createElement("li");
                const eventList = document.getElementById("list");

                newElement.textContent = `message: ${event.data}`;
                eventList.appendChild(newElement);
                };
            </script>
        </head>
        <body>
            <div id="list"></div>
        </body>
    </html>
    """

    return Response(status: .ok, headers: [
        .contentType: "text/html"
    ], body: ResponseBody(byteBuffer: ByteBuffer(string: html)))
}
router.get("events") { req, context in
    let (events, continuation) = AsyncStream<ServerSentEvent>.makeStream()

    // TODO: Emit events into `continuation` using your logic
    let now = ISO8601DateFormatter().string(from: Date())
    continuation.yield(ServerSentEvent(data: SSEValue(string: now)))
    continuation.finish()

    let body = ResponseBody(asyncSequence: events.mapToByteBuffer(allocator: context.allocator))
    return Response(status: .ok, headers: [.contentType: "text/event-stream"], body: body)
}
let app = Application(router: router)
try await app.runService()
