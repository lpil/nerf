# nerf

Gleam bindings to the Erlang [gun][gun] HTTP/1.1, HTTP/2 and Websocket client.

[gun]: https://hex.pm/packages/gun

Currently this library is rather basic and only supports a portion of the
websocket API. Let us know if you need more.

## Usage

This package can be added to your Gleam project like so.

```sh
gleam add nerf
```

Then use it in your Gleam application.

```rust
import nerf/websocket

pub fn main() {
  // Connect
  assert Ok(conn) = websocket.connect("example.com", "/ws", 8080, [])

  // Send some messages
  websocket.send(conn, "Hello")
  websocket.send(conn, "World")

  // Receive some messages
  assert Ok(Text("Hello")) = websocket.receive(conn, 500)
  assert Ok(Text("World")) = websocket.receive(conn, 500)

  // Close the connection
  websocket.close(conn)
}
```

## Testing this library

```sh
podman run --rm --detach -p 8080:8080 --name echo jmalloc/echo-server
gleam test
```
