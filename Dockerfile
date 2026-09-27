FROM ocaml/opam:debian-12-ocaml-5.4

WORKDIR /home/opam/h42n42

RUN sudo apt-get update && sudo apt-get install -y \
    m4 \
    pkg-config \
    libssl-dev \
    libgmp-dev \
    && sudo rm -rf /var/lib/apt/lists/*

RUN opam update && \
    opam install -y \
        eliom \
        js_of_ocaml \
        js_of_ocaml-ppx \
        js_of_ocaml-lwt \
        lwt \
        lwt_ppx

COPY --chown=opam:opam . .

RUN eval $(opam env) && make

EXPOSE 8080

CMD ["sh", "-c", "eval $(opam env) && make run.local"]