(* mirage >= 4.4.1 & < 4.5.0 *)
open Mirage

(* uTCP *)

let tcpv4v6_direct_conf id =
  let packages_v = Key.pure [ package "utcp" ~sublibs:[ "mirage" ] ] in
  let connect _ modname = function
    | [_random; _mclock; _time; ip] ->
      Fmt.str "Lwt.return (%s.connect %S %s)" modname id ip
    | _ -> failwith "direct tcpv4v6"
  in
  impl ~packages_v ~connect "Utcp_mirage.Make"
    (random @-> mclock @-> time @-> ipv4v6 @-> (tcp: 'a tcp typ))

let direct_tcpv4v6
    ?(clock=default_monotonic_clock)
    ?(random=default_random)
    ?(time=default_time) id ip =
  tcpv4v6_direct_conf id $ random $ clock $ time $ ip

let net ?group name netif =
  let ethernet = etif netif in
  let arp = arp ethernet in
  let i4 = create_ipv4 ?group ethernet arp in
  let i6 = create_ipv6 ?group netif ethernet in
  let i4i6 = create_ipv4v6 ?group i4 i6 in
  let tcpv4v6 = direct_tcpv4v6 name i4i6 in
  let ipv4_only = Runtime_key.ipv4_only ?group () in
  let ipv6_only = Runtime_key.ipv6_only ?group () in
  direct_stackv4v6 ~tcp:tcpv4v6 ~ipv4_only ~ipv6_only netif ethernet arp i4 i6

let management_stack =
  let netif = netif ~group:"management" "management" in
  net ~group:"management" "management" netif

let net = net "service" default_network

let setup = runtime_key ~pos:__POS__ "Unikernel.K.setup"

let packages = [
  package "logs" ;
  package "cmarkit" ;
  package ~min:"3.7.1" "tcpip" ;
  package "mirage-monitoring" ;
  package ~sublibs:["mirage"] ~min:"0.4.0" "logs-syslog" ;
  package ~min:"6.1.1" ~sublibs:["mirage"] "dns-certify";
  package "tls-mirage";
  package ~min:"4.3.1" "mirage-runtime";
]

let () =
  register "retreat" [
    main ~runtime_keys:[setup] ~packages "Unikernel.Main"
    (random @-> time @-> pclock @-> stackv4v6 @-> stackv4v6 @-> job)
    $ default_random $ default_time $ default_posix_clock $ net $ management_stack
  ]
