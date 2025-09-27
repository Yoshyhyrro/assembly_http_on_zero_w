open Lwt.Syntax
open Load_balancer

let () =
  let port = 8080 in
  let server = start_server port in
  Lwt_main.run server
