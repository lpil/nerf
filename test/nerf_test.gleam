import gleam/string
import gleam/string_builder
import gleam/bit_builder
import gleeunit
import nerf/websocket.{Binary, Text}

pub fn main() {
  gleeunit.main()
}

pub fn echo_test() {
  // Connect
  assert Ok(conn) = websocket.connect("localhost", "/ws", 8080, [])

  // The server we're using sends a little hello message
  assert Ok(Text(msg)) = websocket.receive(conn, 500)
  assert True = string.starts_with(msg, "Request served by ")

  // Send some messages, the test server echos them back
  websocket.send(conn, "Hello")
  websocket.send(conn, "World")
  assert Ok(Text("Hello")) = websocket.receive(conn, 500)
  assert Ok(Text("World")) = websocket.receive(conn, 500)

  websocket.send_builder(conn, string_builder.from_string("Goodbye"))
  websocket.send_builder(conn, string_builder.from_string("Universe"))
  assert Ok(Text("Goodbye")) = websocket.receive(conn, 500)
  assert Ok(Text("Universe")) = websocket.receive(conn, 500)

  websocket.send_binary(conn, <<1, 2, 3, 4>>)
  websocket.send_binary(conn, <<5, 6, 7, 8>>)
  assert Ok(Binary(<<1, 2, 3, 4>>)) = websocket.receive(conn, 500)
  assert Ok(Binary(<<5, 6, 7, 8>>)) = websocket.receive(conn, 500)

  websocket.send_binary_builder(
    conn,
    bit_builder.from_bit_string(<<8, 7, 6, 5>>),
  )
  websocket.send_binary_builder(
    conn,
    bit_builder.from_bit_string(<<4, 3, 2, 1>>),
  )
  assert Ok(Binary(<<8, 7, 6, 5>>)) = websocket.receive(conn, 500)
  assert Ok(Binary(<<4, 3, 2, 1>>)) = websocket.receive(conn, 500)

  // Close the connection
  websocket.close(conn)
}

pub fn echo_wss_test() {
  // Connect
  assert Ok(conn1) =
    websocket.connect("socketsbay.com", "/wss/v2/2/demo/", 443, [])
  assert Ok(conn2) =
    websocket.connect("socketsbay.com", "/wss/v2/2/demo/", 443, [])

  websocket.send(conn1, "Hello")
  websocket.send(conn2, "World")
  assert Ok(Text("World")) = websocket.receive(conn1, 500)
  assert Ok(Text("Hello")) = websocket.receive(conn2, 500)

  // Close the connection
  websocket.close(conn1)
  websocket.close(conn2)
}
