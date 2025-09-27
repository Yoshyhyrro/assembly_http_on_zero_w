open Http_parser
open Padic_utils
open Lwt.Syntax

(** Memory-efficient hash for Pi Zero - avoid string operations *)
let hash_request path =
  let len = String.length path in
  let sum = ref 0 in
  (* Process only first 16 chars to reduce computation *)
  let max_chars = min len 16 in
  for i = 0 to max_chars - 1 do
    sum := (!sum lsl 1) + Char.code path.[i]
  done;
  !sum mod 3  (* 3 backend servers *)

(** Lightweight request cache for Pi Zero *)
module RequestCache = struct
  let cache_size = 64  (* Small cache for Pi Zero *)
  let cache = Hashtbl.create cache_size
  
  let get path = 
    try Some (Hashtbl.find cache path)
    with Not_found -> None
  
  let put path response =
    if Hashtbl.length cache >= cache_size then
      Hashtbl.clear cache;  (* Simple eviction *)
    Hashtbl.replace cache path response
end

(** Pi Zero optimized application handler *)
let app_handler input =
  (* Quick path extraction without full parsing for cache lookup *)
  let quick_path = 
    try
      let start = String.index input ' ' + 1 in
      let end_pos = String.index_from input start ' ' in
      String.sub input start (end_pos - start)
    with _ -> "/unknown"
  in
  
  (* Check cache first *)
  match RequestCache.get quick_path with
  | Some cached_response -> Lwt.return cached_response
  | None ->
    (* Full parsing only when needed *)
    match parse_request input with
    | Ok req ->
        let backend_idx = hash_request req.path in
        let ports = [8081; 8082; 8083] in
        let target_port = List.nth ports backend_idx in
        let response = Printf.sprintf "Routed to port: %d (ARM optimized)" target_port in
        RequestCache.put req.path response;
        Lwt.return response
    | Error _ -> 
        Lwt.return "Invalid HTTP request"

(** Minimal HTTP response for Pi Zero *)
let format_response content =
  let content_length = String.length content in
  Printf.sprintf "HTTP/1.1 200 OK\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" 
    content_length content

(** Pi Zero optimized server with memory constraints *)
let start_server port =
  (* Configure GC for Pi Zero constraints *)
  Gc.set { 
    (Gc.get ()) with 
    minor_heap_size = 256_000;   (* 256KB minor heap *)
    major_heap_increment = 512_000;  (* 512KB major heap increments *)
    max_overhead = 150;          (* Compact more aggressively *)
  };
  
  let handler _info ic oc =
    let* input = Lwt_io.read_line_opt ic in
    match input with
    | Some request ->
        let* response = app_handler request in
        let formatted_response = format_response response in
        let* () = Lwt_io.write oc formatted_response in
        Lwt_io.flush oc
    | None ->
        Lwt.return_unit
  in
  
  let server = Lwt_io.establish_server 
    ~addr:(Unix.ADDR_INET (Unix.inet_addr_any, port)) 
    handler 
  in
  
  Printf.printf "Pi Zero HTTP Router started on port %d (PID: %d)\n%!" port (Unix.getpid ());
  server
