open Lwt
open V1_LWT

module Main (C : CONSOLE) (CLOCK : PCLOCK) (S : STACKV4) =
struct
  module TCP  = S.TCPV4
  module UDPLOG = Logs_syslog_mirage.Udp(C)(CLOCK)(S.UDPV4)

  let http_header ~status xs =
    let headers = List.map (fun (k, v) -> k ^ ": " ^ v) xs in
    let lines   = status :: headers @ [ "\r\n" ] in
    Cstruct.of_string (String.concat "\r\n" lines)

  let header = http_header
      ~status:"HTTP/1.1 200 OK"
      [ ("Content-Type", "text/html; charset=UTF-8") ;
        ("Connection", "close") ]

  let serve data tcp =
    let (ip, port) = TCP.dst tcp in
    Logs_lwt.info (fun m -> m "%s:%d served" (Ipaddr.V4.to_string ip) port) >>= fun () ->
    TCP.writev tcp [ header; data ] >>= fun _ ->
    TCP.close tcp

  let start con clock stack =
    let reporter =
      let ip = Ipaddr.V4.of_string_exn "198.167.222.206" in
      UDPLOG.create con clock (S.udpv4 stack) ~hostname:"marrakech2017.mirage.io" ip ()
    in
    Logs.set_reporter reporter ;
    S.listen_tcpv4 stack ~port:80 (serve Page.rendered) ;
    S.listen stack

end
