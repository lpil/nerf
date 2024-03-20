import gleam/http.{type Header}
import gleam/dynamic.{type Dynamic}
import gleam/result
import gleam/string_builder.{type StringBuilder}
import gleam/bytes_builder.{type BytesBuilder}
import nerf/gun.{type ConnectionPid, type StreamReference}

pub opaque type Connection {
  Connection(ref: StreamReference, pid: ConnectionPid)
}

pub fn connect(
  hostname: String,
  path: String,
  on port: Int,
  with headers: List(Header),
) -> Result(Connection, ConnectError) {
  use pid <- result.try(
    gun.open(hostname, port)
    |> result.map_error(ConnectionFailed),
  )
  use _ <- result.try(
    gun.await_up(pid)
    |> result.map_error(ConnectionFailed),
  )

  // Upgrade to websockets
  let ref = gun.ws_upgrade(pid, path, headers)
  let conn = Connection(pid: pid, ref: ref)
  use _ <- result.try(
    await_upgrade(conn, 1000)
    |> result.map_error(ConnectionFailed),
  )

  // TODO: handle upgrade failure
  // https://ninenines.eu/docs/en/gun/2.0/guide/websocket/
  // https://ninenines.eu/docs/en/gun/1.2/manual/gun_error/
  // https://ninenines.eu/docs/en/gun/1.2/manual/gun_response/
  Ok(conn)
}

pub fn send(to conn: Connection, this message: String) -> Nil {
  ws_send(conn, gun.Text(message))
}

pub fn send_builder(to conn: Connection, this message: StringBuilder) -> Nil {
  ws_send(conn, gun.TextBuilder(message))
}

pub fn send_binary(to conn: Connection, this message: BitArray) -> Nil {
  ws_send(conn, gun.Binary(message))
}

pub fn send_binary_builder(to conn: Connection, this message: BytesBuilder) -> Nil {
  ws_send(conn, gun.BinaryBuilder(message))
}

@external(erlang, "nerf_ffi", "ws_receive")
pub fn receive(from: Connection, within: Int) -> Result(gun.Frame, Nil)

@external(erlang, "nerf_ffi", "ws_await_upgrade")
fn await_upgrade(from: Connection, within: Int) -> Result(Nil, Dynamic)

// TODO: listen for close events
pub fn close(conn: Connection) -> Nil {
  ws_send(conn, gun.Close)
}

/// The URI of the websocket server to connect to
pub type ConnectError {
  ConnectionRefused(status: Int, headers: List(Header))
  ConnectionFailed(reason: Dynamic)
}

type OkAtom

@external(erlang, "nerf_ffi", "ws_send_erl")
fn ws_send_erl(conn: Connection, frame: gun.Frame) -> OkAtom

pub fn ws_send(conn: Connection, frame: gun.Frame) -> Nil {
  ws_send_erl(conn, frame)
  Nil
}
