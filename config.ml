open Mirage

let address =
  let network = Ipaddr.V4.Prefix.of_address_string_exn "198.167.222.204/24"
  and gateway = Ipaddr.V4.of_string "198.167.222.1"
  in
  { network ; gateway }

let net =
  if_impl Key.is_unix
    (socket_stackv4 [Ipaddr.V4.any])
    (static_ipv4_stack ~config:address default_network)

let packages = [
  package ~sublibs:["lwt"] "logs" ;
  package ~sublibs:["mirage"] "logs-syslog" ;
  package "omd" ;
  package "tyxml" ;
]

let () =
  register "marrakech" [
    foreign
      ~packages
      "Unikernel.Main"
      ( console @-> pclock @-> stackv4 @-> job )
    $ default_console
    $ default_posix_clock
    $ net
  ]
