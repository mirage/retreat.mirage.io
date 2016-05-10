open Lwt
open V1_LWT

module Main (S : STACKV4) =
struct
  module TCP  = S.TCPV4

  let http_header ~status xs =
    let headers = List.map (fun (k, v) -> k ^ ": " ^ v) xs in
    let lines   = status :: headers @ [ "\r\n" ] in
    Cstruct.of_string (String.concat "\r\n" lines)

  let header = http_header
      ~status:"HTTP/1.1 200 OK"
      [ ("Content-Type", "text/html; charset=UTF-8") ;
        ("Connection", "close") ]

  let serve data tcp =
    TCP.writev tcp [ header; data ] >>= fun _ ->
    TCP.close tcp

  let rendered =
    Cstruct.of_string
      (String.concat "" [
          "<html><head>" ;
          "<title>1st MirageOS hackathon: 11-16th March 2016, Marrakech, Morocco</title>" ;
          "<style>" ; Style.data ; "</style>" ;
          "</head>" ;
          "<body><div id=\"content\">" ;
          Content.data ;
          "</div></body></html>" ])

  let start stack _ =
    S.listen_tcpv4 stack ~port:80 (serve rendered) ;
    S.listen stack

end
