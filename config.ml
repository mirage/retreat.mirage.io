open Mirage

let monitor =
  let doc = Key.Arg.info ~doc:"monitor host IP" ["monitor"] in
  Key.(create "monitor" Arg.(opt (some ip_address) None doc))

let syslog =
  let doc = Key.Arg.info ~doc:"syslog host IP" ["syslog"] in
  Key.(create "syslog" Arg.(opt (some ip_address) None doc))

let name =
  let doc = Key.Arg.info ~doc:"Name of the unikernel" ["name"] in
  Key.(create "name" Arg.(opt string "retreat.mirage.io" doc))

let net = generic_stackv4v6 default_network

let management_stack =
  generic_stackv4v6 ~group:"management" (netif ~group:"management" "management")

let packages = [
  package ~sublibs:["lwt"] "logs" ;
  package "omd" ;
  package ~min:"4.5.0" "tyxml" ;
  package ~min:"3.7.1" "tcpip" ;
  package "mirage-monitoring" ;
  package ~sublibs:["mirage"] ~min:"0.3.0" "logs-syslog" ;
]

let () =
  register "retreat" [
    foreign
      ~keys:[ Key.v name ; Key.v syslog ; Key.v monitor ]
      ~packages
      "Unikernel.Main"
    (console @-> time @-> pclock @-> stackv4v6 @-> stackv4v6 @-> job)
    $ default_console $ default_time $ default_posix_clock $ net $ management_stack
  ]
