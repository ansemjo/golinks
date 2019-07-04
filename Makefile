SRC = $(shell find web/assets -maxdepth 1 -type f)
DST = $(patsubst %.sass,%.css,$(patsubst %.ts,%.js,$(subst web/assets,.build/assets,$(SRC))))

NODEBIN := .build/node_modules/.bin

ALL: web/bindata.go

.build/bin/go-bindata:
	GO111MODULE=off GOPATH=$(shell pwd)/.build go get github.com/jteeuwen/go-bindata/...

$(NODEBIN)/sass $(NODEBIN)/tsc $(NODEBIN)/google-closure-compiler:
	npm -C $(shell pwd)/.build --silent install sass typescript google-closure-compiler

.build/assets:
	mkdir -p $@

.build/assets/%.css: web/assets/%.sass $(NODEBIN)/sass
	$(NODEBIN)/sass --style=compressed --no-source-map $< $@

.build/assets/%.js: web/assets/%.ts $(NODEBIN)/tsc $(NODEBIN)/google-closure-compiler
	$(eval TMP := $(shell mktemp))
	$(NODEBIN)/tsc --out $(TMP) $< 
	$(NODEBIN)/google-closure-compiler --js $(TMP) --js_output_file $@
	rm -f $(TMP)

.build/assets/%: web/assets/%
	cp $< $@

web/bindata.go: .build/bin/go-bindata .build/assets $(DST)
	$< -o $@ -pkg web -prefix .build/assets -nomemcopy .build/assets/...

clean:
	rm -rf .build/assets web/bindata.go