# Works with GNU Make and BSD Make
.PHONY: default setup prepare build build-css release
default: dev

nodebin := node_modules/.bin
main := src/Main.elm
port := 8000
server := $(nodebin)/webpack-dev-server --hot --inline --port $(port)

################################################################################
# Setup
################################################################################

setup:
	git submodule init
	git submodule update
	npm install
	elm-package install -y

################################################################################
# Compile
################################################################################

compile:
	elm-make $(main)

compile-clean:
	$(MAKE) compile && rm -f index.html

compile-loop:
	-while :; do $(MAKE) compile; sleep 2; done

################################################################################
# Build
################################################################################

prepare:
	rm -rf build/ && \
	mkdir -p build/css && \
	mkdir -p build/js && \
	mkdir -p build/vendor && \
	cp -r static/css/* build/css && \
	cp -r static/js/* build/js && \
	cp -r static/vendor/* build/vendor

build: prepare
	cat static/index.html > build/index.html

build-css: prepare
	sed 's/ \
	  <\/body/ \
	  \<script type\=\"text\/javascript\" src\=\"vendor\/cssrefresh.js\"\>\<\/script\> \
	  &/' static/index.html > build/index.html

release: build
	npm run build
	tar -zcf release.tar.gz build/ && mv release.tar.gz build/

################################################################################
# Dev
################################################################################

# For dev, first we compile the whole app, and only then we run npm.
# The rationale is simple: `npm start` will compile with debug and warn
# flags, which makes the whole step much slower. Compiling first without
# them ensures the "bulk" of the job is done quickly, and only then we
# add the debug flags. There is little difference when only a couple
# of changes are made, but it makes everything much faster when the
# whole app, with dependencies, need to be built. This usually happens
# when adding dependencies, changing branches etc.
dev: compile-clean build
	npm start

# Add annoying css hot reloader. Useful when editing styles.
dev-css: compile-clean build-css
	npm start

################################################################################
# Tools
################################################################################

server:
	$(server)

# We repeat the lint command as a hack to ignore badly formatted code on vendor/
# This way, we can display which HEBorn files are not complying with the style
# guide AND THEN return the relevant status code.
# If we remove vendor/, below can be simplified to `elm-format --validate src/`
lint:
	elm-format --validate src/ | grep -v vendor
	elm-format --validate src/ | grep -v vendor | wc -l | grep 1

################################################################################
# Test
################################################################################

test:
	$(nodebin)/elm-test

test-quick:
	sed 's/10/1/g' tests/Config.elm > tests/Config.elm.tmp && \
	mv tests/Config.elm.tmp tests/Config.elm
	$(MAKE) test
	git checkout tests/Config.elm

test-long:
	sed 's/10/100/g' tests/Config.elm > tests/Config.elm.tmp && \
	mv tests/Config.elm.tmp tests/Config.elm
	$(MAKE) test
	git checkout tests/Config.elm

test-loop:
	- while :; do $(MAKE) test; sleep 2; done

################################################################################
# Clean
################################################################################

clean:
	rm -rf build/* && \
	rm -f *.html && \
	rm -f release.tar.gz && \
	git clean -id && \
	git checkout tests/Config.elm