open Lwt
open V1
open V1_LWT

module Main (C : CONSOLE) (S : STACKV4) =
struct
  module TCP  = S.TCPV4

  let http_header ~status xs =
    let headers = List.map (fun (k, v) -> k ^ ": " ^ v) xs in
    let lines   = status :: headers @ [ "\r\n" ] in
    Cstruct.of_string (String.concat "\r\n" lines)

  let header = http_header
      ~status:"HTTP/1.1 200 OK"
      [ ("content-type", "text/html; charset=UTF-8") ]

  let serve data =
    fun tcp ->
      TCP.writev tcp [ header; data ] >>= fun _ -> TCP.close tcp

  let rendered =
    Cstruct.of_string
      ("<html><head><title>1st MirageOS hackathon: 11-16th March 2016, Marrakech, Morocco</title><style>" ^ Style.data ^ "</style></head><body><div id=\"content\">" ^ Content.data ^ "</div></body></html>")

  let start con stack =
    S.listen_tcpv4 stack ~port:80 (serve rendered) ;
    S.listen stack

end
