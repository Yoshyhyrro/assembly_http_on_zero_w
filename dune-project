(lang dune 3.0)

(package
 (name ocaml-http-router)
 (depends
  ocaml
  dune
  lwt
  angstrom
  lwt_ppx
  alcotest
  (conf-libev :build)))

(executables
 (public_names ocaml-http-router))

; Cross-compilation configuration for Raspberry Pi Zero W
(env
 (cross-compile
  (flags (:standard -ccopt -static))
  (ocamlopt_flags (:standard -compact))))
