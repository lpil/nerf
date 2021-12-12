import gleam/erlang
import gleam/erlang/atom
import gleam/string
import gleeunit
import gleeunit/should
import nerf/websocket.{Text}

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
