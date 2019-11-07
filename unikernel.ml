open Lwt.Infix

module Main (C : Mirage_console.S) (T : Mirage_time.S) (M : Mirage_clock.MCLOCK) (P : Mirage_clock.PCLOCK) (S : Mirage_stack.V4) (Management : Mirage_stack.V4) = struct
  module TCP = S.TCPV4

  let http_header ~status xs =
    let headers = List.map (fun (k, v) -> k ^ ": " ^ v) xs in
    let lines = status :: headers @ [ "\r\n" ] in
    Cstruct.of_string (String.concat "\r\n" lines)

  let header len = http_header
      ~status:"HTTP/1.1 200 OK"
      [ ("Content-Type", "text/html; charset=UTF-8") ;
        ("Content-length", string_of_int len) ;
        ("Connection", "close") ]

  let incr_access =
    let s = ref 0 in
    let open Metrics in
    let doc = "access statistics" in
    let data () =
      Data.v [
        int "total http responses" !s ;
      ] in
    let src = Src.v ~doc ~tags:Tags.[] ~data "http" in
    (fun () ->
       s := succ !s;
       Metrics.add src (fun x -> x) (fun d -> d ()))

  let serve data tcp =
    incr_access ();
    TCP.writev tcp data >>= fun _ ->
    TCP.close tcp

  module Monitoring = Monitoring_experiments.Make(T)(Management)
  module Syslog = Logs_syslog_mirage.Udp(C)(P)(Management)

  let start c _time _mclock _pclock stack management info =
    let hostname = Key_gen.name ()
    and syslog = Key_gen.syslog ()
    and monitor = Key_gen.monitor ()
    in
    if Ipaddr.V4.compare syslog Ipaddr.V4.unspecified = 0 then
      Logs.warn (fun m -> m "no syslog specified, dumping on stdout")
    else
      Logs.set_reporter (Syslog.create c management syslog ~hostname ());
    if Ipaddr.V4.compare monitor Ipaddr.V4.unspecified = 0 then
      Logs.warn (fun m -> m "no monitor specified, not outputting statistics")
    else
      Monitoring.create ~hostname monitor management;
    List.iter (fun (p, v) -> Logs.app (fun m -> m "used package: %s %s" p v))
      info.Mirage_info.packages;
    let data =
      let content_size = Cstruct.len Page.rendered in
      [ header content_size ; Page.rendered ]
    in
    S.listen_tcpv4 stack ~port:80 (serve data) ;
    S.listen stack
end
