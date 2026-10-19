# kflux install targets (used by packaging/arch/*/PKGBUILD).
#   make install DESTDIR=/tmp/root PREFIX=/usr
#   make install-kflux
PREFIX ?= /usr
DESTDIR ?=
SHARE := $(DESTDIR)$(PREFIX)/share
VERSION ?= $(shell git describe --tags --always 2>/dev/null || echo 0.1)

.PHONY: install install-kflux check

install: install-kflux

install-kflux:
	install -Dm755 overlay/usr/bin/kflux          $(DESTDIR)$(PREFIX)/bin/kflux
	install -Dm755 overlay/usr/bin/kflux-session  $(DESTDIR)$(PREFIX)/bin/kflux-session
	install -Dm644 overlay/usr/lib/kflux/session-env $(DESTDIR)$(PREFIX)/lib/kflux/session-env
	install -Dm644 overlay/usr/share/wayland-sessions/kflux.desktop $(SHARE)/wayland-sessions/kflux.desktop
	install -Dm644 overlay/usr/share/xdg-desktop-portal/kflux-portals.conf $(SHARE)/xdg-desktop-portal/kflux-portals.conf
	install -d $(SHARE)/kflux/skel $(SHARE)/kflux/styles $(SHARE)/kflux/keys.d
	install -m644 overlay/usr/share/kflux/skel/* $(SHARE)/kflux/skel/
	install -m644 overlay/usr/share/kflux/keys.d/* $(SHARE)/kflux/keys.d/
	cp -r overlay/usr/share/kflux/styles/. $(SHARE)/kflux/styles/
	install -Dm644 README.md  $(SHARE)/doc/kflux/README.md
	install -Dm644 NOTICE.md  $(SHARE)/doc/kflux/NOTICE.md
	install -Dm644 docs/USAGE.md $(SHARE)/doc/kflux/USAGE.md
	install -Dm644 LICENSE    $(SHARE)/licenses/kflux/LICENSE
	install -Dm644 LICENSES/Fluxbox-MIT.txt $(SHARE)/licenses/kflux/Fluxbox-MIT.txt

check:
	python3 -m py_compile overlay/usr/bin/kflux
	sh -n overlay/usr/bin/kflux-session
