open Lwt.Infix

module K = struct
  open Cmdliner

  let key =
    Arg.conv ~docv:"HOST:HASH:DATA" Dns.Dnskey.(name_key_of_string, pp_name_key)

  let dns_key =
    let doc = Arg.info ~doc:"nsupdate key (name:type:value,...)" ["dns-key"] in
    Arg.(value & opt (some key) None doc)

  let dns_server =
    let doc = Arg.info ~doc:"dns server IP" ["dns-server"] in
    Arg.(value & opt (some Mirage_runtime_network.Arg.ip_address) None doc)

  let dns_port =
    let doc = Arg.info ~doc:"dns server port" ["dns-port"] in
    Arg.(value & opt int 53 doc)

  let key =
    let doc = Arg.info ~doc:"certificate key (<type>:seed or b64)" ["key"] in
    Arg.(value & opt (some string) None doc)

  let hostname =
    let doc = Arg.info ~doc:"Name of the unikernel" ["name"] in
    Arg.(value & opt string "retreat.mirage.io" doc)

  let no_tls =
    let doc = Arg.info ~doc:"Disable TLS" [ "no-tls" ] in
    Arg.(value & flag doc)

  let http_port =
    let doc = Arg.info ~doc:"Listening HTTP port." ["http"] ~docv:"PORT" in
    Arg.(value & opt int 80 doc)

  let https_port =
    let doc = Arg.info ~doc:"Listening HTTPS port." ["https"] ~docv:"PORT" in
    Arg.(value & opt int 443 doc)

  type t = {
    dns_key : ([`raw] Domain_name.t * Dns.Dnskey.t) option;
    dns_server : Ipaddr.t option;
    dns_port : int;
    key : string option;
    no_tls : bool;
    hostname : string;
    http_port : int;
    https_port : int;
  }

  let v dns_key dns_server dns_port key no_tls hostname http_port https_port =
    { dns_key; dns_server; dns_port; key; no_tls; hostname; http_port; https_port }

  let setup =
    Term.(const v $ dns_key $ dns_server $ dns_port $ key $ no_tls
          $ hostname $ http_port $ https_port)

end

module Main (R : Mirage_crypto_rng_mirage.S) (T : Mirage_time.S) (P : Mirage_clock.PCLOCK) (S : Tcpip.Stack.V4V6) (Management : Tcpip.Stack.V4V6) = struct
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

  let start _random _time _pclock stack management arg =
    let hostname = Domain_name.(host_exn (of_string_exn arg.K.hostname)) in
    let data =
      let content_size = Cstruct.length Page.rendered in
      [ header content_size ; Page.rendered ]
    in
    (if not arg.no_tls then
       match arg.dns_key, arg.dns_server, arg.key with
       | None, _, _ | _, None, _ | _, _, None ->
         Logs.err (fun m -> m "TLS operations requires dns-key, dns-server, and key arguments");
         exit Mirage_runtime.argument_error
       | Some dns_key, Some dns_server, Some key ->
         let key_type, key_data, key_seed =
           match String.split_on_char ':' key with
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
           stack ~dns_key:(Fmt.to_to_string Dns.Dnskey.pp_name_key dns_key)
           ~hostname ~key_type ?key_data ?key_seed
           dns_server arg.dns_port >|= function
         | Error (`Msg msg) ->
           Logs.err (fun m -> m "error while requesting certificate: %s" msg);
           exit Mirage_runtime.argument_error
         | Ok certificates ->
           let certificates = `Single certificates in
           match Tls.Config.server ~certificates () with
           | Error `Msg msg ->
             Logs.err (fun m -> m "error while building TLS configuration: %s" msg);
             exit Mirage_runtime.argument_error
           | Ok tls_config ->
             Logs.info (fun m -> m "listening for HTTPS on port %u" arg.https_port);
             S.TCP.listen (S.tcp stack) ~port:arg.https_port (serve_tls tls_config data)
     else
       Lwt.return_unit) >>= fun () ->
    Logs.info (fun m -> m "listening for HTTP in port %u" arg.http_port);
    S.TCP.listen (S.tcp stack) ~port:arg.http_port (serve data) ;
    S.listen stack
end
