open Angstrom

type http_method = GET | POST | PUT | DELETE
type request = {
  method_type: http_method;
  path: string;
  version: string;
}

let method_parser =
  choice [
    string "GET" *> return GET;
    string "POST" *> return POST;
    string "PUT" *> return PUT;
    string "DELETE" *> return DELETE;
  ]

let path_parser = 
  char '/' *> take_while (fun c -> c <> ' ')

let version_parser =
  string "HTTP/" *> take_while (fun c -> c <> '\r')

let request_line =
  method_type <$> method_parser <*> (char ' ' *> path_parser) <*> (char ' ' *> version_parser)
  >>| fun (method_type, path, version) -> { method_type; path; version }

let parse_request input =
  parse_string request_line input
