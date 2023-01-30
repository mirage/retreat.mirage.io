open Lwt.Infix

module Main (C : Mirage_console.S) (R : Mirage_random.S) (T : Mirage_time.S) (P : Mirage_clock.PCLOCK) (S : Tcpip.Stack.V4V6) (Management : Tcpip.Stack.V4V6) = struct
  module Dns_certify = Dns_certify_mirage.Make(R)(P)(T)(S)
  module TLS = Tls_mirage.Make(S.TCP)

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

  let serve_tls cfg data tcp_flow =
    incr_access ();
    TLS.server_of_flow cfg tcp_flow >>= function
    | Ok tls_flow ->
      TLS.writev tls_flow data >>= fun _ ->
      TLS.close tls_flow
    | Error e ->
      Logs.warn (fun m -> m "TLS error %a" TLS.pp_write_error e);
      S.TCP.close tcp_flow

  module Monitoring = Mirage_monitoring.Make(T)(P)(Management)
  module Syslog = Logs_syslog_mirage.Udp(C)(P)(Management)

  let start c _random _time _pclock stack management =
    let hostname = Key_gen.name () in
    (match Key_gen.syslog () with
     | None -> Logs.warn (fun m -> m "no syslog specified, dumping on stdout")
     | Some ip -> Logs.set_reporter (Syslog.create c management ip ~hostname ()));
    (match Key_gen.monitor () with
     | None -> Logs.warn (fun m -> m "no monitor specified, not outputting statistics")
     | Some ip -> Monitoring.create ~hostname ip management);
    let hostname = Domain_name.(host_exn (of_string_exn hostname)) in
    let key_type, key_data, key_seed =
      match String.split_on_char ':' (Key_gen.key ()) with
      | [ typ ; data ] ->
        (match X509.Key_type.of_string typ with
         | Ok `RSA -> `RSA, None, Some data
         | Ok x -> x, Some data, None
         | Error `Msg msg ->
           Logs.err (fun m -> m "Error decoding key type: %s" msg);
           exit Mirage_runtime.argument_error)
      | _ ->
        Logs.err (fun m -> m "expected for key type:data");
        exit Mirage_runtime.argument_error
    in
    Dns_certify.retrieve_certificate
      stack ~dns_key:(Key_gen.dns_key ())
      ~hostname ~key_type ?key_data ?key_seed
      (Key_gen.dns_server ()) (Key_gen.dns_port ()) >>= function
    | Error (`Msg m) -> Lwt.fail_with m
    | Ok certificates ->
      let certificates = `Single certificates in
      let tls_config = Tls.Config.server ~certificates () in
      let data =
        let content_size = Cstruct.length Page.rendered in
        [ header content_size ; Page.rendered ]
      in
      S.TCP.listen (S.tcp stack) ~port:80 (serve data) ;
      S.TCP.listen (S.tcp stack) ~port:443 (serve_tls tls_config data);
      S.listen stack
end
