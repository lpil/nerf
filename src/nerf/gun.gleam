//// Low level bindings to the gun API. You typically do not need to use this.
//// Prefer the other modules in this library.

import gleam/http.{Header}
import gleam/erlang/charlist.{Charlist}
import gleam/dynamic.{Dynamic}
import gleam/option.{Option}
import gleam/string_builder.{StringBuilder}
import gleam/bit_builder.{BitBuilder}

pub external type StreamReference

pub external type ConnectionPid

pub type Protocols {
  Http
  Http2
  HttpAndHttp2
}

pub type Transports {
  Tls
  Tcp
}

// Missing: http_opts, http2_opts, transport_opts, ws_opts
/// [gun:opts() type](https://ninenines.eu/docs/en/gun/1.3/manual/gun/)
pub type Options {
  Options(
    /// Connection timeout.
    connect_timeout: Option(Int),
    /// Ordered list of preferred protocols. When the transport is `tcp`, this list must contain exactly one protocol.
    /// When the transport is `tls`, this list must contain at least one protocol and will
    /// be used to negotiate a protocol via ALPN. When the server does not support ALPN then
    /// http will always be used. Defaults to `[http]` when the transport is `tcp`, and `[http2, http]`
    /// when the transport is `tls`.
    protocols: Option(Protocols),
    /// Whether to use TLS or plain TCP. The default varies depending on the port used. Port 443
    /// defaults to `tls`. All other ports default to `tcp`.
    transport: Option(Transports),
    /// Number of times Gun will try to reconnect on failure before giving up.
    retry: Option(Int),
    /// Time between retries in milliseconds.
    retry_timeout: Option(Int),
    /// Whether to enable `dbg` tracing of the connection process. Should only be used during debugging.
    trace: Option(Bool),
  )
}

/// Internal options type that perfectlt matches
type InternalOptions {
  InternalOptions(
    /// Connection timeout.
    connect_timeout: Option(Int),
    /// Ordered list of preferred protocols. When the transport is `tcp`, this list must contain exactly one protocol.
    /// When the transport is `tls`, this list must contain at least one protocol and will
    /// be used to negotiate a protocol via ALPN. When the server does not support ALPN then
    /// http will always be used. Defaults to `[http]` when the transport is `tcp`, and `[http2, http]`
    /// when the transport is `tls`.
    protocols: Option(Protocols),
    /// Whether to use TLS or plain TCP. The default varies depending on the port used. Port 443
    /// defaults to `tls`. All other ports default to `tcp`.
    transport: Option(List(Transports)),
    /// Number of times Gun will try to reconnect on failure before giving up.
    retry: Option(Int),
    /// Time between retries in milliseconds.
    retry_timeout: Option(Int),
    /// Whether to enable `dbg` tracing of the connection process. Should only be used during debugging.
    trace: Option(Bool),
  )
}

/// Run [gun:open()](https://ninenines.eu/docs/en/gun/1.3/manual/gun.open) using the default options
pub fn open(host: String, port: Int) -> Result(ConnectionPid, Dynamic) {
  open_erl(charlist.from_string(host), port)
}

fn to_internal_opts(opts: Options) -> InternalOptions {
  let protocols = case opts.protocols {
    Some(p) ->
      case p {
        Some(Http) -> [Http]
        Some(Http2) -> [Http2]
        Some(HttpAndHttp2) -> [Http, Http2]
      }
    None -> None
  }

  InternalOptions(
    connect_timeout: opts.connect_timeout,
    protocols: protocols,
    transport: opts.transport,
    retry: opts.retry,
    retry_timeout: opts.retry_timeout,
    trace: opts.trace,
  )
}

/// Run [gun:open()](https://ninenines.eu/docs/en/gun/1.3/manual/gun.open) with the ability to pass custom options
pub fn open_with_options(
  host: String,
  port: Int,
  opts: Options,
) -> Result(ConnectionPid, Dynamic) {
  open_erl_with_options(
    charlist.from_string(host),
    port,
    to_internal_opts(opts),
  )
}

pub external fn open_erl(Charlist, Int) -> Result(ConnectionPid, Dynamic) =
  "nerf_ffi" "ws_open"

pub external fn open_erl_with_options(
  Charlist,
  Int,
  InternalOptions,
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
