open Alcotest
open Ocaml_http_router.Padic_utils

let test_p_adic_distance () =
  let dist = p_adic_distance 2 8 12 in
  check (float 0.01) "p-adic distance" 0.25 dist

let test_filter_requests () =
  let requests = [
    { id = 4; path = "/api/test"; deps = [2; 8] };
    { id = 6; path = "/api/data"; deps = [2; 4] };
  ] in
  let filtered = filter_requests 1.0 2 requests in
  check int "filtered count" 2 (List.length filtered)

let () =
  run "p-adic tests" [
    ("distance", Quick, test_p_adic_distance);
    ("filter", Quick, test_filter_requests);
  ]
