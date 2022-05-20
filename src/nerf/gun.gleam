//// Low level bindings to the gun API. You typically do not need to use this.
//// Prefer the other modules in this library.

import gleam/http.{Header}
import gleam/erlang/charlist.{Charlist}
import gleam/dynamic.{Dynamic}
import gleam/option.{Option}

pub external type StreamReference

pub external type ConnectionPid

pub type Protocols {
  Http
  Http2
}

pub type Transports {
  Tls
  Tcp
}

// Missing: http_opts, http2_opts, transport_opts, ws_opts
pub type Options {
  Options(
    connect_timeout: Option(Int),
    protocols: Option(List(Protocols)),
    transport: Option(Transports),
    retry: Option(Int),
    retry_timeout: Option(Int),
    trace: Option(Bool),
  )
}

pub fn open(host: String, port: Int) -> Result(ConnectionPid, Dynamic) {
  open_erl(charlist.from_string(host), port)
}

pub fn open_with_options(
  host: String,
  port: Int,
  opts: Options,
) -> Result(ConnectionPid, Dynamic) {
  open_erl_with_options(charlist.from_string(host), port, opts)
}

pub external fn open_erl(Charlist, Int) -> Result(ConnectionPid, Dynamic) =
  "nerf_ffi" "ws_open"

pub external fn open_erl_with_options(
  Charlist,
  Int,
  Options,
) -> Result(ConnectionPid, Dynamic) =
  "nerf_ffi" "ws_open"

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
}

external type OkAtom

external fn ws_send_erl(ConnectionPid, Frame) -> OkAtom =
  "gun" "ws_send"

pub fn ws_send(pid: ConnectionPid, frame: Frame) -> Nil {
  ws_send_erl(pid, frame)
  Nil
}
