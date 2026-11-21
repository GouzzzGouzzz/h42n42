DUNE_DIR=main/

all:
	dune build
	-cp _build/default/src/client/main.bc.js static/h42n42.js
	dune exec -- ocsigenserver -c h42n42.conf.in

.PHONY: all
