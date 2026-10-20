# kflux install targets, used by packaging/arch/kflux/PKGBUILD, the VM image
# build (tools/container/build-image.sh) and tools/push-dev.sh.
#   make install DESTDIR=/tmp/root PREFIX=/usr
# Portable to BSD install(1): no `install -D`.
PREFIX ?= /usr
DESTDIR ?=
BIN   := $(DESTDIR)$(PREFIX)/bin
LIB   := $(DESTDIR)$(PREFIX)/lib/kflux
SHARE := $(DESTDIR)$(PREFIX)/share
DOC   := $(SHARE)/doc/kflux
LIC   := $(SHARE)/licenses/kflux

.PHONY: install check

install:
	install -d $(BIN) $(LIB) $(SHARE)/kflux/skel $(SHARE)/kflux/keys.d $(SHARE)/kflux/styles \
	  $(SHARE)/wayland-sessions $(SHARE)/xdg-desktop-portal $(DOC) $(LIC)
	install -m755 src/kflux src/kflux-session $(BIN)/
	install -m644 src/session-env $(LIB)/
	install -m644 data/skel/* $(SHARE)/kflux/skel/
	install -m644 data/keys.d/* $(SHARE)/kflux/keys.d/
	cp -R data/styles/. $(SHARE)/kflux/styles/
	install -m644 data/kflux.desktop $(SHARE)/wayland-sessions/
	install -m644 data/kflux-portals.conf $(SHARE)/xdg-desktop-portal/
	install -m644 README.md NOTICE.md CHANGELOG.md docs/USAGE.md $(DOC)/
	install -m644 LICENSE LICENSES/Fluxbox-MIT.txt $(LIC)/

check:
	python3 -m py_compile src/kflux
	sh -n src/kflux-session
	sh -n src/session-env
