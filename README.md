# nerf

Gleam bindings to [gun][gun], the Erlang HTTP/1.1, HTTP/2 and Websocket client.

[gun]: https://hex.pm/packages/gun

Currently this library is rather basic and only supports a portion of the
websocket API, and TLS is not verified!

## Usage

This package can be added to your Gleam project like so.

```sh
gleam add nerf
```

Then use it in your Gleam application.

```rust
import nerf/websocket
import gleam/erlang
import gleam/erlang/atom

pub fn main() {
  // Start the implicit Erlang applications required
  let app = atom.create_from_string("your_project_name")
  assert Ok(_) = erlang.ensure_all_started(app)

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
