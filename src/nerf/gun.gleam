//// Low level bindings to the gun API. You typically do not need to use this.
//// Prefer the other modules in this library.

import gleam/http.{type Header}
import gleam/erlang/charlist.{type Charlist}
import gleam/dynamic.{type Dynamic}
import gleam/string_builder.{type StringBuilder}
import gleam/bytes_builder.{type BytesBuilder}

pub opaque type StreamReference

pub opaque type ConnectionPid

pub fn open(host: String, port: Int) -> Result(ConnectionPid, Dynamic) {
  open_erl(charlist.from_string(host), port)
}

@external(erlang, "gun", "open")
pub fn open_erl(host: Charlist, port: Int) -> Result(ConnectionPid, Dynamic)

@external(erlang, "gun", "await_up")
pub fn await_up(conn: ConnectionPid) -> Result(Dynamic, Dynamic)

@external(erlang, "gun", "ws_upgrade")
pub fn ws_upgrade(
  conn: ConnectionPid,
  path: String,
  headers: List(Header),
) -> StreamReference

pub type Frame {
  Close
  Text(String)
  Binary(BitArray)
  TextBuilder(StringBuilder)
  BinaryBuilder(BytesBuilder)
}
