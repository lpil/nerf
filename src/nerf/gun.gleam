//// Low level bindings to the gun API. You typically do not need to use this.
//// Prefer the other modules in this library.

import gleam/http.{Header}
import gleam/erlang/charlist.{Charlist}
import gleam/dynamic.{Dynamic}
import gleam/string_builder.{StringBuilder}
import gleam/bit_builder.{BitBuilder}
import nerf/opts.{ConnectionOpts}

pub external type StreamReference

pub external type ConnectionPid

pub fn open(
  host: String,
  port: Int,
  opts: ConnectionOpts,
) -> Result(ConnectionPid, Dynamic) {
  let opts_map =
    opts
    |> opts.to_gun_format
    |> opts.map_from_list

  open_erl(charlist.from_string(host), port, opts_map)
}

external fn open_erl(Charlist, Int, Dynamic) -> Result(ConnectionPid, Dynamic) =
  "gun" "open"

pub external fn await_up(ConnectionPid) -> Result(Dynamic, Dynamic) =
  "gun" "await_up"

pub external fn ws_upgrade(
  ConnectionPid,
  String,
  List(Header),
) -> StreamReference =
  "gun" "ws_upgrade"

pub type Frame {
  Close
  Text(String)
  Binary(BitString)
  TextBuilder(StringBuilder)
  BinaryBuilder(BitBuilder)
}

external type OkAtom

external fn ws_send_erl(ConnectionPid, Frame) -> OkAtom =
  "nerf_ffi" "ws_send_erl"

pub fn ws_send(pid: ConnectionPid, frame: Frame) -> Nil {
  ws_send_erl(pid, frame)
  Nil
}
