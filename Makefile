NAME = h42n42

DUNE_DIR=main/

PACKAGES = -y \
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


# Build

all:
	dune build
	-cp _build/default/src/client/main.bc.js static/h42n42.js

clean:
	dune clean
	-rm -f static/h42n42.js

fclean: clean

re: fclean all

## Run

run: all
	dune exec -- ocsigenserver -c h42n42.conf.in

rerun: re run


# Init

install:
	opam init --no-setup
	opam switch create $(NAME) 5.4.1 || true
	opam install -y $(PACKAGES) || true
	@echo "Run: eval \$$(opam env)"

dev:
	opam init --auto-setup
	opam switch create $(NAME) 5.4.1 || true
	opam install -y $(PACKAGES) || true
	opam install -y ocamlformat dot-merlin-reader ocaml-lsp-server

uninstall:
	opam switch remove -y $(NAME)

.PHONY: all clean fclean re install
