open Mirage

let net = generic_stackv4 default_network

let packages = [
  package ~sublibs:["lwt"] "logs" ;
  package "omd" ;
  package "tyxml" ;
  package ~min:"3.7.1" "tcpip" ;
]

let () =
  register "retreat" [
    foreign
      ~packages
      "Unikernel.Main"
      ( stackv4 @-> job )
    $ net
  ]
