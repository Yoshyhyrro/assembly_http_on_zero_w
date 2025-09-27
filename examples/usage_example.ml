(* Example usage of the HTTP router with p-adic filtering *)
open Ocaml_http_router.Padic_utils
open Ocaml_http_router.Load_balancer

let example_requests = [
  { id = 10; path = "/api/users"; deps = [2; 5] };
  { id = 15; path = "/api/posts"; deps = [10; 12] };
  { id = 20; path = "/api/comments"; deps = [15] };
]

let () =
  Printf.printf "Example p-adic distances:\n";
  Printf.printf "d_2(10, 15) = %f\n" (p_adic_distance 2 10 15);
  Printf.printf "d_3(10, 15) = %f\n" (p_adic_distance 3 10 15);
  
  Printf.printf "\nFiltered requests (threshold=1.0, p=2):\n";
  let filtered = filter_requests 1.0 2 example_requests in
  List.iter (fun req -> 
    Printf.printf "ID: %d, Path: %s\n" req.id req.path
  ) filtered
