open Lwt.Infix

module Main (C : Mirage_console.S) (T : Mirage_time.S) (P : Mirage_clock.PCLOCK) (S : Tcpip.Stack.V4V6) (Management : Tcpip.Stack.V4V6) = struct
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
    S.TCP.writev tcp data >>= fun _ ->
    S.TCP.close tcp

  module Monitoring = Mirage_monitoring.Make(T)(P)(Management)
  module Syslog = Logs_syslog_mirage.Udp(C)(P)(Management)

  let start c _time _pclock stack management =
    let hostname = Key_gen.name () in
    (match Key_gen.syslog () with
     | None -> Logs.warn (fun m -> m "no syslog specified, dumping on stdout")
     | Some ip -> Logs.set_reporter (Syslog.create c management ip ~hostname ()));
    (match Key_gen.monitor () with
     | None -> Logs.warn (fun m -> m "no monitor specified, not outputting statistics")
     | Some ip -> Monitoring.create ~hostname ip management);
    let data =
      let content_size = Cstruct.length Page.rendered in
      [ header content_size ; Page.rendered ]
    in
    S.TCP.listen (S.tcp stack) ~port:80 (serve data) ;
    S.listen stack
end
