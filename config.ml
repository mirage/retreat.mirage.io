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

let net = generic_stackv4 default_network

let management_stack =
  generic_stackv4v6 ~group:"management" (netif ~group:"management" "management")

let packages = [
  package ~sublibs:["lwt"] "logs" ;
  package "omd" ;
  package "tyxml" ;
  package ~min:"3.7.1" "tcpip" ;
  package ~min:"0.0.2" "monitoring-experiments" ;
  package ~sublibs:["mirage"] "logs-syslog" ;
]

let () =
  register "retreat" [
    foreign
      ~keys:[ Key.abstract name ; Key.abstract syslog ; Key.abstract monitor ]
      ~packages
      "Unikernel.Main"
    (console @-> time @-> pclock @-> stackv4 @-> stackv4v6 @-> job)
    $ default_console $ default_time $ default_posix_clock $ net $ management_stack
  ]
