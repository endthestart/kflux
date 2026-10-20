# Building and testing kflux

## Repository layout

```
src/            kflux (the translator and session helper; Python, stdlib only),
                kflux-session (session entry), session-env (shared environment)
data/           skel/ (default init, keys, apps, menu, windowmenu, slitlist, startup),
                keys.d/, styles/kflux-Carbon, the session .desktop and portals config
patches/        labwc-tabs.patch: the labwc-kflux patch (GPL-2.0-only)
packaging/      arch/kflux, arch/labwc-kflux (PKGBUILD, .SRCINFO), make-dist.sh
docs/           user guide, ADRs (adr/), release procedure, images
tools/          test image build, VM runner, verify.sh and dev-loop scripts
  container/    the in-container image build
  rootfs/       files only the test image gets (greetd autologin)
experimental/   fluxland/: the parked fluxland session (ADR 0004)
```

`make install DESTDIR=… PREFIX=/usr` is the single install mapping. The
PKGBUILD, the test image and `tools/push-dev.sh` all use it. `make check`
byte-compiles the translator and syntax-checks the shell scripts.

## The test image

`tools/build.sh` builds a CachyOS disk image with kflux and labwc-kflux
installed, for QEMU. It runs on macOS (Apple Silicon) with Homebrew `colima`,
`docker` and `qemu`. The build uses its own Colima profile, `kflux` (4 vCPU,
4 GiB), and stops it afterwards. Inside an amd64 `cachyos/cachyos` container
it:

1. pacstraps the packages in [tools/packages.txt](../tools/packages.txt)
2. builds `labwc-kflux` with makepkg from its PKGBUILD, cached by input hash
3. installs kflux with `make install`, and the image-only files from `tools/rootfs/`
4. writes a GPT/UEFI disk (systemd-boot, ext4 root) without loop devices and
   converts it to `vm/kflux.qcow2`

`tools/build.sh --with-fluxland` also builds the experimental fluxland session.

```bash
tools/run-vm.sh              # a window; --headless for VNC on 127.0.0.1:5921
tools/verify.sh              # checks against the booted VM; exit status = failures
tools/screenshot.sh          # PNG of the VM screen, into .cache/screenshots/
ssh -i .cache/ssh/id_ed25519 -p 2232 flux@127.0.0.1
```

`run-vm.sh` uses KVM on Linux, HVF on Intel Macs and TCG elsewhere. The VM logs
in automatically as `flux` (password `flux`): test credentials for a local VM
only. Build and test use open-source tools only: QEMU, OVMF and pacstrap
([ADR 0007](adr/0007-open-source-tooling.md)).

## Dev loop against the running VM

- `tools/push-dev.sh [--reset]` installs the working tree into the VM and runs
  `kflux reconfigure`; `--reset` re-seeds `~/.config/kflux`.
- `tools/vm-ssh.sh --wl CMD` runs CMD inside the Wayland session's environment.
- `tools/vm-input.py click X Y right`, `keys ctrl alt right` and
  `drag X1 Y1 X2 Y2 ctrl` send pointer and keyboard input over QMP.
- `tools/preview.sh STYLE` renders stock labwc and Waybar headless in the
  builder container, without the VM.
- `tools/clean.sh [--all]` reclaims the builder volumes, and with `--all` the
  image and the Colima profile.

## Packages

To build the packages from the working tree before a release exists:

```bash
packaging/make-dist.sh 0.2.0
cd packaging/arch/kflux && KFLUX_SRC=file:///path/to/kflux-0.2.0.tar.gz makepkg -f --skippgpcheck
```

Releases: [RELEASING.md](RELEASING.md).
