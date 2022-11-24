import gleam/erlang/atom.{Atom}

pub type TlsVerify {
  VerifyNone
  VerifyPeer
}

pub type ConnectionTransport {
  Tls(verify: TlsVerify)
  Tcp
}

pub type ConnectionOpts {
  ConnectionOpts(transport: ConnectionTransport)
}

//

pub type GunConnectionOptsTransportOpt {
  Verify(Atom)
}

pub type GunConnectionOpt {
  Transport(Atom)
  TransportOpts(List(GunConnectionOptsTransportOpt))
}

pub fn to_gun_format(conn_opts: ConnectionOpts) -> List(GunConnectionOpt) {
  let tcp = atom.create_from_string("tcp")
  let tls = atom.create_from_string("tls")
  // tls transport opts
  let verify_none = atom.create_from_string("verify_none")

  case conn_opts {
    ConnectionOpts(transport: Tcp) -> [Transport(tcp)]
    ConnectionOpts(transport: Tls(verify: VerifyPeer)) -> [Transport(tls)]
    ConnectionOpts(transport: Tls(verify: VerifyNone)) -> [
      Transport(tls),
      TransportOpts([Verify(verify_none)]),
    ]
  }
}

pub external fn map_from_list(list: List(a)) -> m =
  "maps" "from_list"
