open Mirage

let net = generic_stackv4 default_network

let logger = syslog_udp ~config:(syslog_config ~truncate:1484 "retreat") net

let packages = [
  package ~sublibs:["lwt"] "logs" ;
  package "omd" ;
  package "tyxml" ;
]

let () =
  register "retreat" [
    foreign
      ~deps:[ abstract logger ; abstract app_info ]
      ~packages
      "Unikernel.Main"
      ( stackv4 @-> job )
    $ net
  ]
