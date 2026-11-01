(lang dune 3.10)

(dialect
 (name "eliom-server")
 (implementation
  (extension "eliom"))
 (interface
  (extension "eliomi")))


(name h42n42)
(generate_opam_files true)


(package
 (allow_empty)
 (name h42n42)
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.10))
  (eliom (>= 10.0))
  (js_of_ocaml (>= 5.0))
  js_of_ocaml-ppx
  js_of_ocaml-lwt
  lwt
  lwt_ppx)); Opam dependencies

