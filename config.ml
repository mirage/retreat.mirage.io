open Mirage

let address =
  let network = Ipaddr.V4.Prefix.of_address_string_exn "198.167.222.204/24"
  and gateway = Ipaddr.V4.of_string "198.167.222.1"
  in
  { network ; gateway }

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~config:address ~arp:arp' default_network)

let logger =
  syslog_udp
    (syslog_config ~truncate:1484 "marrakech2017.mirage.io" (Ipaddr.V4.of_string_exn "198.167.222.206"))
    net

let packages = [
  package ~sublibs:["lwt"] "logs" ;
  package "omd" ;
  package "tyxml" ;
]

let () =
  register "marrakech" [
    foreign
      ~deps:[abstract logger]
      ~packages
      "Unikernel.Main"
      ( stackv4 @-> job )
    $ net
  ]
