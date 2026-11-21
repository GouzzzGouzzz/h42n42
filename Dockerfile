FROM ocaml/opam:debian-12-ocaml-5.4

WORKDIR /home/opam/h42n42

RUN mkdir -p local/logs local/data

RUN sudo apt-get update

RUN opam install -y \
    dune.3.24.2 \
    binaryen-bin.119 \
    eliom.12.1.0 \
    ocsigenserver.7.0.0 \
    js_of_ocaml.6.4.1 \
    js_of_ocaml-ppx.6.4.1 \
    js_of_ocaml-lwt.6.4.1 \
    lwt.6.1.2 \
    lwt_ppx.6.1.0 \
    ocsigen-ppx-rpc.1.1 \
    ocsipersist-sqlite.2.1.0\
    ocsipersist.2.1.0 \
    ocsipersist-sqlite-config.2.1.0

COPY --chown=opam:opam . .

RUN eval $(opam env) && dune build \
    && cp _build/default/src/client/main.bc.js static/h42n42.js

EXPOSE 8080

CMD ["dune", "exec", "--", "ocsigenserver", "-c", "h42n42.conf.in"]
