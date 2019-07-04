.DEFAULT_GOAL := assets.go

#------------ binaries required for build ------------#

# go asset bundler
.build/bin/go-bindata:
	GO111MODULE=off GOPATH=$(shell pwd)/.build go get github.com/jteeuwen/go-bindata/...

# typescript/javascript transpiler, sass preprocessor
NODEBIN := .build/node_modules/.bin
SASS    := $(NODEBIN)/sass
TSC     := $(NODEBIN)/tsc
CLOSURE := $(NODEBIN)/google-closure-compiler
$(SASS) $(TSC) $(CLOSURE):
	npm -C $(shell pwd)/.build --silent install sass typescript google-closure-compiler

#------------ build and copy static assets ------------#

# find assets
ASSETS := $(shell find assets/ -maxdepth 1 -type f)
ASSETS := $(patsubst %.sass,%.css,$(patsubst %.ts,%.js,$(subst assets,.build/assets,$(ASSETS))))

.build/assets:
	mkdir -p $@

# stylesheet
.build/assets/%.css: assets/%.sass .build/assets $(SASS)
	$(SASS) --style=compressed --no-source-map $< $@

# optimized javascript
.build/assets/%.js: assets/%.ts .build/assets $(TSC) $(CLOSURE)
	$(TSC) --out /dev/stdout $< |\
	  $(CLOSURE) --js /dev/stdin --js_output_file $@

# other assets
.build/assets/%: assets/% .build/assets
	cp $< $@

# generate embedded static files
assets.go: .build/bin/go-bindata .build/assets $(ASSETS)
	$< -o $@ -pkg web -prefix .build/assets -nomemcopy .build/assets/...

#------------ miscellaneous ------------#

.PHONY: clean
clean:
	rm -rf .build/assets assets.go