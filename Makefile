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

all:
	docker-compose up --build

clean:
	docker-compose down

fclean:
	docker-compose down --rmi all --remove-orphans

re: fclean all

.PHONY: all clean fclean re

# Local build (No docker)

local-all:
	mkdir -p local/logs local/data
	dune build
	-cp -u _build/default/src/client/main.bc.js static/h42n42.js

local-clean:
	dune clean
	-rm -f static/h42n42.js

local-fclean: local-clean
	rm -rf local/

local-re: local-fclean local-all

## Run

local-run: local-re local-all
	dune exec -- ocsigenserver -c h42n42.conf.in

# Init

dev-install:
	opam init --no-setup
	opam switch create $(NAME) 5.4.1 || true
	opam install -y $(PACKAGES) || true
	@echo "Run: eval \$$(opam env)"

dev-uninstall:
	opam switch remove -y $(NAME)

dev:
	opam init --auto-setup
	opam switch create $(NAME) 5.4.1 || true
	opam install -y $(PACKAGES) || true
	opam install -y ocamlformat dot-merlin-reader ocaml-lsp-server

.PHONY: local-all local-clean local-fclean local-re dev-install dev-uninstall dev
