open Mirage

let address addr nm gw =
  let f = Ipaddr.V4.of_string_exn in
  { address = f addr ; netmask = f nm ; gateways = [f gw] }

let server = address "198.167.222.204" "255.255.255.0" "198.167.222.1"

let net =
  match get_mode () with
  | `Unix -> socket_stackv4 default_console [Ipaddr.V4.any]
  | `Xen  -> direct_stackv4_with_static_ipv4 default_console tap0 server

(* Shell commands to run at configure time *)
type shellconfig = ShellConfig
let shellconfig = Type ShellConfig

let config_shell = impl @@ object
    inherit base_configurable

    method configure i =
      let open Functoria_app.Cmd in
      let (>>=) = Rresult.(>>=) in
      let dir = Info.root i in
      run "echo 'let data = {___|' > data/style.ml" >>= fun () ->
      run "cat data/style.css >> data/style.ml" >>= fun () ->
      run "echo '|___}' >> data/style.ml" >>= fun () ->
      run "echo 'let data = {___|' > data/content.ml" >>= fun () ->
      run "omd data/content.md >> data/content.ml" >>= fun () ->
      run "echo '|___}' >> data/content.ml"

    method clean i = Functoria_app.Cmd.run "rm data/style.ml data/content.ml"

    method module_name = "Functoria_runtime"
    method name = "shell_config"
    method ty = shellconfig
end

let () =
  register "marrakech2016" [
    foreign
      ~deps:[abstract config_shell]
      "Unikernel.Main"
      ( stackv4 @-> job )
      $ net
  ]
