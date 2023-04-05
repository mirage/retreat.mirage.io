open Mirage

let dns_key =
  let doc = Key.Arg.info ~doc:"nsupdate key (name:type:value,...)" ["dns-key"] in
  Key.(create "dns-key" Arg.(required string doc))

let dns_server =
  let doc = Key.Arg.info ~doc:"dns server IP" ["dns-server"] in
  Key.(create "dns-server" Arg.(required ip_address doc))

let dns_port =
  let doc = Key.Arg.info ~doc:"dns server port" ["dns-port"] in
  Key.(create "dns-port" Arg.(opt int 53 doc))

let key =
  let doc = Key.Arg.info ~doc:"certificate key (<type>:seed or b64)" ["key"] in
  Key.(create "key" Arg.(required string doc))

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
  package ~max:"2.0.0~alpha3" "omd" ;
  package ~min:"4.5.0" "tyxml" ;
  package ~min:"3.7.1" "tcpip" ;
  package "mirage-monitoring" ;
  package ~sublibs:["mirage"] ~min:"0.3.0" "logs-syslog" ;
  package ~min:"6.1.1" ~sublibs:["mirage"] "dns-certify";
  package "tls-mirage";
  package ~min:"4.3.1" "mirage-runtime";
]

let () =
  register "retreat" [
    foreign
      ~keys:[
        Key.v dns_key ; Key.v dns_server ; Key.v dns_port ; Key.v key ;
        Key.v name ; Key.v syslog ; Key.v monitor
      ]
      ~packages
      "Unikernel.Main"
    (console @-> random @-> time @-> pclock @-> stackv4v6 @-> stackv4v6 @-> job)
    $ default_console $ default_random $ default_time $ default_posix_clock $ net $ management_stack
  ]
