FROM ocaml/opam:debian-12-ocaml-5.4

WORKDIR /home/opam/h42n42

RUN sudo apt-get update && sudo apt-get install -y

RUN opam update && \
    opam install -y \
    binaryen-bin.119 \
    eliom \
    js_of_ocaml \
    js_of_ocaml-ppx \
    js_of_ocaml-lwt \
    lwt \
    lwt_ppx \
    ocsigen-ppx-rpc \
    ocsipersist-sqlite \
    ocsipersist \
    ocsipersist-sqlite-config \

EXPOSE 8080

