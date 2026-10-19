# Third-party notices

kflux is MIT-licensed ([LICENSE](LICENSE)). It includes or derives from:

| What | From | Licence | Notes |
|---|---|---|---|
| `overlay/usr/share/kflux/skel/keys`, and the menu, windowmenu and init formats and defaults | Fluxbox 1.3.7 `data/keys`, `data/windowmenu`, `data/init.in` | MIT, © 2001–2011 The Fluxbox Team; Blackbox portions © 1997–2000 Brad Hughes | Full text: [LICENSES/Fluxbox-MIT.txt](LICENSES/Fluxbox-MIT.txt) |
| `third_party/patches/fluxland-wlroots-0.20.patch`, and the `fluxland-kflux` package built from it | [ecliptik/fluxland](https://github.com/ecliptik/fluxland) at commit `32d1009` | MIT, © the fluxland authors | The package installs fluxland's LICENSE. The patch is offered under the same MIT terms. `third_party/fluxland/` is a local upstream checkout and is not part of the kflux repo |
| `third_party/patches/labwc-tabs.patch`, and the `labwc-kflux` package built from it | [labwc](https://github.com/labwc/labwc) 0.20.2 | **GPL-2.0-only**, © the labwc authors | The patch modifies labwc and is offered under labwc's GPL-2.0-only, not kflux's MIT. The package is labwc plus the patch |

Used at runtime but **not** included. They're installed from distribution
packages and converted on the user's machine:

| What | Licence | Credit |
|---|---|---|
| Fluxbox styles in `/usr/share/fluxbox/styles` (the `fluxbox` package) | Fluxbox tree (MIT). tenner's styles carry **CC BY-SA 3.0** notices: arch, bloe, bora_black, bora_blue, bora_green, carp, green_tea, ostrich, zimek_bisque, zimek_darkblue, zimek_green | tenner (Sven Michel, tenr.de); skypher; Pax; mack@incise.org; joel carlbark; ikaro; BioNiK; xlife; the Fluxbox team |
| Terminus font (`ttf-terminus-nerd`) | SIL OFL 1.1 | Dimitar Zhekov |
| labwc, Waybar, mako, swaybg, swaylock, conky, KDE Plasma, Frameworks and apps | their own licences (GPL-2.0, MIT, GPL/LGPL) | their authors |

If a future release bundles any CC BY-SA style, keep its header, ship it under
CC BY-SA with attribution, and keep it apart from the MIT code.
