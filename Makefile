PROJECT= wseg

CC= gcc

lib: wseg.cma wseg.cmxa

wseg.cma: wseg.ml
	ocamlfind ocamlc -g -package base,stdio,trie,pcre,camomile -a -o $@ $^

wseg.cmxa: wseg.ml
	ocamlfind ocamlopt -g -package base,stdio,trie,pcre,camomile -a -o $@ $^

wseg.ml: wseg.cmi


wseg.cmi: wseg.mli
	ocamlfind ocamlc -package base,stdio,trie,pcre,camomile $<

.PHONY: install clean

install: lib
	ocamlfind install $(PROJECT) META *.mli *.cmi *.cma *.cmxa *.a

uninstall:
	ocamlfind remove $(PROJECT)

test: test.byte
	./test.byte

test.byte: test.ml lib
	ocamlfind ocamlc -linkpkg -g -package base,stdio,pcre,camomile,trie wseg.cma -o $@ $<

clean:
	rm -f *.annot *.o *.cm* *.a
	rm -f test.byte

