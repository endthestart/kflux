# Fluxbox culture, styles and reuse: the 2003-2010 desktop

Researched 2026-10-18. Companion to [01-fluxbox-features.md](01-fluxbox-features.md), which covers features and file formats; not repeated here.

## Method and limits

- Style tree: GitHub API and raw files for `fluxbox/fluxbox` `master` (`data/styles`, `COPYING`, `data/keys`), plus per-style commit history.
- Community catalogue: the Pling/OpenDesktop OCS API (`api.pling.com`), which returned all 318 results for "fluxbox". The `pling.com` and `opendesktop.org` HTML listings rendered as empty templates.
- Other live sources: AUR RPC, Gentoo, Fedora repoview, Debian and Ubuntu file lists, GitHub repo metadata, and forum threads.
- Wayback captures were fetched with curl, since WebFetch refuses web.archive.org.
- Not verified: the MX Linux forum (403 from Cloudflare), the Gentoo 2003 thread (login wall), live tenr.de (HTTP 404 on http, DNS failure on https; the 2016 capture was used), and GitHub code-search counts (rate-limited and noisy, so dropped).
- No images or archives were downloaded.

## Headlines

- The fluxbox tree ships 27 styles: 14 single files and 13 directories. Eleven directories (tenner's) carry CC BY-SA 3.0 notices. The other 16 have no licence text, and 8 of them have no author line either. The code and tree are MIT ([COPYING](https://github.com/fluxbox/fluxbox/blob/master/COPYING)).
- Pling holds 197 "Fluxbox Themes". 100 of them (51%) were created in 2007-2009, so the peak era is visible in the catalogue ([OCS API](https://api.pling.com/ocs/v1/content/data?search=fluxbox&pagesize=100&format=json)).
- In a captured LinuxQuestions "Window Manager of the Year" poll, Fluxbox took 214 of 753 votes (28.42%), the top spot ([thread, 2018 capture](https://web.archive.org/web/20180805214457/http://www.linuxquestions.org/questions/showthread.php?s=&threadid=116368)).
- The most consistent desktop recipe in the 2005-2008 threads is conky or torsmo stats, iDesk icons, a transparent aterm or urxvt, and gkrellm or dockapps.
- labwc's themerc texture section defines only Solid and Gradient (Vertical or SplitVertical). Bevels, interlacing and diagonals have no equivalent ([labwc-theme(5)](https://github.com/labwc/labwc/blob/master/docs/labwc-theme.5.scd)).
- No tool named fbox2obox exists. The nearest are ob-2-fb (Openbox 3 to Fluxbox, BSD) and Openbox's themeupdate.py (Fluxbox to Openbox 3, GPL-2).
- [ecliptik/fluxland](https://github.com/ecliptik/fluxland) (MIT, Wayland, 17 stars) claims to read Fluxbox style files directly. It is prior art to check before writing a parser.

## 1. Styles

### 1a. Shipped in the fluxbox tree (`data/styles`, master)

The [master tree](https://github.com/fluxbox/fluxbox/tree/master/data/styles) holds these entries. The [Makemodule](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Makemodule.am) lists the 14 single files. Origin is taken from the file header where one exists, otherwise from the earliest commit in the history (`fluxgen` for all entries).

| Style | Kind | Origin | Look (from file) | Licence text in file |
|---|---|---|---|---|
| Artwiz | file | no author line; first commit 2001-12-11 | Toolbar raised vertical gradient, rgb 80/84/88 to 30/34/38; pressed buttons sunken diagonal to blue 80/98/d0; X core font lucidatypewriter ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Artwiz)) | none |
| BlueNight | file | "Blue Night v2", mack@incise.org (2001-12-31), tweaked by skypher | Flat background rgb 6A/9A/AF; diagonal gradient buttons ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/BlueNight)) | none |
| Flux | file | no author line; 2001 import | Flat navy toolbar rgb 6/6/54; labels flat crossdiagonal gradient, rgb 8/8/7 to f/f/d; text 2/2/1c; font lucidasans-10 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Flux)) | none |
| LemonSpace | file | xlife@zuavra.net | Raised vertical gradient, tan rgb cb/ac/73; needs the Snap font from the Artwiz pack ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/LemonSpace)) | none; asks for derivatives to be sent to the author |
| Makro | file | skypher of perplexity, 2001 | Sunken vertical gradient, rgb CC/CC/AA; flat buttons rgb AB/90/40 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Makro)) | none |
| MerleyKay | file | skypher, 2001; based on "Simple Elegance" by Pax, credited | Raised vertical gradient, slate rgb 62/70/85 to 56/66/75 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/MerleyKay)) | none; Pax credit only |
| Meta | file | joel carlbark, (c) 2003; committed "from joel" 2003-02-23 | Flat vertical gradient #849ec6 to #526d8c; needs font glisp; "please dont turn on aa" ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Meta)) | none |
| Nyz | file | no author line; 2001 | Flat diagonal gradient toolbar, rgb 6/9/c to 4/6/8 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Nyz)) | none |
| Operation | file | no author line; 2001 | Flat crossdiagonal gradient, same colours as Nyz ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Operation)) | none |
| Outcomes | file | no author line; 2001 | Raised diagonal bevel1 gradient; pressed buttons sunken interlaced ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Outcomes)) | none |
| Results | file | no author line; 2001 | Same family as Outcomes; title bars raised diagonal bevel1 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Results)) | none |
| Shade | file | no author line; 2001 | Flat solid near-black rgb 6/6/6; labels flat crossdiagonal gradient ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Shade)) | none |
| Twice | file | no author line; 2001 | Flat diagonal gradient, maroon rgb c/6/6 to 8/4/4 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Twice)) | none |
| qnx-photon | file | skypher, 2001 | Raised vertical gradient, light grey rgb DB/DA/DB to D4/CE/D2 ([file](https://github.com/fluxbox/fluxbox/blob/master/data/styles/qnx-photon)) | "(c) skypher" only |
| BlueFlux | dir | BioNiK, 2003; "edited from skypher's theme" ([theme.cfg](https://github.com/fluxbox/fluxbox/blob/master/data/styles/BlueFlux/theme.cfg)) | not sampled | none |
| Emerge | dir | ikaro, 2003-09-14; "Simple desktop, clean and stylish" ([theme.cfg](https://github.com/fluxbox/fluxbox/blob/master/data/styles/Emerge/theme.cfg)) | Raised bevel1 gradient; menu frame #ffffff to #ebebeb; black text | none |
| arch, bloe, carp, green_tea | dir | tenner (Sven Michel), tenr.de; headers dated 2006, repo commit 2007-09-30 ([commits](https://github.com/fluxbox/fluxbox/commits/master/data/styles/arch)) | menu fonts sans-9/10 bold, shadowed title ([arch](https://github.com/fluxbox/fluxbox/blob/master/data/styles/arch/theme.cfg)) | CC BY-SA 3.0 (de) header |
| bora_black, bora_blue, bora_green, zimek_bisque, zimek_darkblue, zimek_green | dir | tenner; added 2007-09-18 and 2007-09-30 ([commit](https://github.com/fluxbox/fluxbox/commits/master/data/styles/zimek_green)) | not sampled | CC BY-SA 3.0 (de) header |
| ostrich | dir | tenner (inferred from the 2007-09-30 commit) | not sampled | CC BY-SA 3.0 header ([theme.cfg](https://github.com/fluxbox/fluxbox/blob/master/data/styles/ostrich/theme.cfg)) |

Notes:

- tenr.de's own page says every style download contains the GIMP `.xcf` source ([tenr.de/styles, 2016 capture](https://web.archive.org/web/20161228095256/http://tenr.de/styles/)).
- Debian stable's fluxbox package ships the upstream set plus extras not in the upstream tree: Bity_fluxbox, Doty, Squared_blue, Squared_for_Debian, Squared_green, debian-blue, debian-dark ([file list](https://packages.debian.org/stable/amd64/fluxbox/filelist)). Ubuntu noble lists 33 style entries ([file list](https://packages.ubuntu.com/noble/amd64/fluxbox/filelist)).

### 1b. Community catalogue (Pling / OpenDesktop)

Ranked by the search-field download counter from the [OCS API](https://api.pling.com/ocs/v1/content/data?search=fluxbox&pagesize=100&format=json). Licence is the uploader's tag, read from the detail endpoint.

| Rank | Style | Author | Downloads | Created | Licence tag |
|---|---|---|---|---|---|
| 1 | [Ambiance Crunchy](https://www.pling.com/p/1017085) | frombenny | 2886 | 2013-10-13 | gplv3 |
| 2 | [FluxMatcha](https://www.pling.com/p/1732288) | itzselenux | 1670 | 2022-03-13 | none |
| 3 | [Matrix-Flux](https://www.pling.com/p/1017099) | Overflow | 1321 | 2010-03-10 | none |
| 4 | [Fluxbox Blossom](https://www.pling.com/p/1319453) | eXpander | 1175 | 2019-08-18 | gplv2-later |
| 5 | [Ciremai (Yosemite)](https://www.pling.com/p/1016926) | ekaputra | 986 | 2015-09-21 | none |
| 6 | [Dark Fluxbox](https://www.pling.com/p/1016898) | Ake | 864 | 2014-10-10 | none |
| 7 | [gnw](https://www.pling.com/p/1162407) | nggit | 857 | 2016-11-19 | none |
| 8 | [FluxCDE](https://www.pling.com/p/1016906) | dmbaturin | 753 | 2009-11-21 | none |
| 9 | [Fluxbox_Gray](https://www.pling.com/p/1244393) | nUmer | 741 | 2018-06-30 | gplv2-later |
| 10 | [Cyanized - Tron-like](https://www.pling.com/p/1016958) | eXpander | 732 | 2011-11-12 | mit-license |

Other items with a clear era or licence signal:

- [Solaris: Java Fluxbox System](https://www.pling.com/p/1017098) (vermaden, 2007-07-30, 670 downloads, no tag).
- [Milly](https://www.pling.com/p/1360216) (eXpander, mit-license, 653) and [Unicorn](https://www.pling.com/p/1336283) (eXpander, mit-license, 579). The same eXpander styles Blossom, Milly and Unicorn appear in [xexpanderx/Fluxbox-themes](https://github.com/xexpanderx/Fluxbox-themes).
- [Clearlooks Fluxbox style](https://www.pling.com/p/1017005) (GotF, 2012, 498, no tag).
- [Simple-AdwaitaDark](https://www.pling.com/p/1686462) (cc-by-sa, 527) and [Simple-ArcDark](https://www.pling.com/p/1690655) (cc-by-sa and bsd, 603).

Pattern: 11 of the top 30 declare a licence tag. The other 19 declare none, so they are all rights reserved by default. Download counts are from the search endpoint; the detail endpoint differs slightly (Ambiance Crunchy reports 2742 there). Many 2016-2022 entries are GTK ports (Adwaita-Flux, Flux Numix, FluxMint, Adapta-for-Fluxbox) rather than Fluxbox-native looks.

Pling's Fluxbox style counts per creation year: 2007 (32), 2008 (32), 2009 (36), 2010 (16), 2011 (14), 2012 (9), 2013-2022 between 3 and 11 a year, then 1-2 a year to 2026.

### 1c. Other distribution and archive sources

- **tenr.de** (Sven "tenner" Michel): the 2016 capture lists about 16 pages of styles and a nightly tarball, `tenr.de-styles-pkg.tar.bz2` ([styles index](https://web.archive.org/web/20161018231550/http://tenr.de/styles/)). Its about page licenses the work as "Creative Commons Attribution-Share Alike 3.0 Germany" ([about, 2016](https://web.archive.org/web/20161018231550/http://tenr.de/about/)). Also includes styles from the defunct fluxmod.dk.
- **Gentoo** `x11-themes/fluxbox-styles-fluxmod` (version 20050128-r1): "A collection of FluxBox themes from FluxMod", homepage tenr.de/styles, licence GPL-2 ([Gentoo](https://packages.gentoo.org/packages/x11-themes/fluxbox-styles-fluxmod)).
- **Fedora** `tenr-de-styles-pkg`: "A collection of styles for fluxbox", licence "Creative Commons Attribution-ShareAlike 2.5", with a version bump that added over 100 styles ([repoview](https://pubmirror.math.uh.edu/fedora-buffet/archive/fedora/linux/extras/5/ppc/repoview/tenr-de-styles-pkg.html)).
- **FreeBSD** `x11-themes/fluxbox-tenr-styles-pack` ([FreshPorts](https://www.freshports.org/x11-themes/fluxbox-tenr-styles-pack), search snippet only).
- **AUR** `fluxbox-style-*` packages, with votes and declared licence from the [AUR RPC](https://aur.archlinux.org/rpc/?v=5&type=search&by=name&arg=fluxbox):
  - numix (5 votes), zukitwo (5), mint-x (5), elegant-brit (3), greybird (0), hellbent (2), solarized-light (2), jet-gray (0). The last four were not checked.
  - numix, zukitwo, mint-x and elegant-brit declare GPL3. Source is [corebob/fluxbox-styles-corebob](https://github.com/corebob/fluxbox-styles-corebob).
  - fluxbox-arc-dark (6 votes, GPL3, [son-link/fluxbox-arc-dark](https://github.com/son-link/fluxbox-arc-dark)).
- **box-look.org** now redirects to [opendesktop.org window managers](https://www.opendesktop.org/s/window-managers/browse/), so the Pling/OpenDesktop catalogue above is its successor.
- **BunsenLabs forum, 2015-10-29**: recommends box-look.org, customize.org and tenr.de for Fluxbox styles ([post](https://forums.bunsenlabs.org/viewtopic.php?pid=5313)).

### 1d. Style collections on GitHub

Star counts and push dates are from the GitHub API on 2026-10-18.

| Repo | Stars | Last push | Licence (GitHub) | Notes |
|---|---|---|---|---|
| [pld-linux/fluxbox-styles](https://github.com/pld-linux/fluxbox-styles) | 1 | 2026-04-04 | none | Pack of styles |
| [wachin/fluxbox-styles-themes--from-MX-Linux-antiX-23](https://github.com/wachin/fluxbox-styles-themes--from-MX-Linux-antiX-23) | 0 | 2026-07-15 | none | 13 families from MX and antiX 23 (LemonSpacePro2, MX-Squared, MX-comfort, Numix, PrettyPink, niroki, sleek2flux, others). README: "may carry their own license comments" |
| [bytting/fluxbox-styles-corebob](https://github.com/bytting/fluxbox-styles-corebob) | 1 | 2016-08-20 | GPL-3.0 | Source for the AUR numix, zukitwo, mint-x and elegant-brit packages |
| [mmitch/fluxbox-styles-mitch](https://github.com/mmitch/fluxbox-styles-mitch) | 1 | 2010-10-02 | none | Old personal pack |
| [h3xx/fluxbox-style-solaris](https://github.com/h3xx/fluxbox-style-solaris) | 3 | 2022-11-25 | none | CDE-like |
| [aktsbot/fluxbox-style-rayne](https://github.com/aktsbot/fluxbox-style-rayne) | 2 | 2022-12-07 | none | Dark flat |
| [aktsbot/fluxbox-style-chicago95](https://github.com/aktsbot/fluxbox-style-chicago95) | 0 | 2024-01-16 | none | Pairs with the Chicago95 GTK theme |
| [lvirgili/fluxbox-solarized](https://github.com/lvirgili/fluxbox-solarized) | 6 | 2013-12-01 | none | Solarized palette |
| [son-link/fluxbox-arc-dark](https://github.com/son-link/fluxbox-arc-dark) | 6 | 2016-06-06 | GPL-3.0 | Port of Arc GTK theme |
| [adam-stokes/tenr.de-fluxbox-styles](https://github.com/adam-stokes/tenr.de-fluxbox-styles) | 1 | 2016-09-20 | NOASSERTION | Archive of tenr styles |
| [KDCar15/fluxbox-styles](https://github.com/KDCar15/fluxbox-styles) | 1 | 2025-09-22 | none | Personal styles |
| [xexpanderx/Fluxbox-themes](https://github.com/xexpanderx/Fluxbox-themes) | 166 | 2020-11-27 | none | Batti, Blossom, Clover, DaftP, Milly, Unicorn, WFlux, WFlux2, WorkFlux, Zombie, cilia |

xexpanderx has the most stars of the style-only repos (166). Its Blossom, Milly and Unicorn styles also appear on Pling under eXpander, with 579 to 1175 downloads each.

## 2. Screenshot culture

### 2a. Popularity signals

- **Window Manager of the Year poll** (thread created 2003-11-15; figures from the 2018 capture): Fluxbox 214 votes (28.42%), KWin 123 (16.33%), MetaCity 93 (12.35%), Window Maker 86 (11.42%), IceWM 84 (11.16%), Enlightenment 62 (8.23%), Blackbox 42 (5.58%), Openbox 20 (2.66%). 753 voters ([LinuxQuestions](https://web.archive.org/web/20180805214457/http://www.linuxquestions.org/questions/showthread.php?s=&threadid=116368)).
- **fluxbox.org screenshots page** (2018 capture): links to LinuxQuestions award threads for 2003 and 2004 and to a Softonic 2003 award ([page](https://web.archive.org/web/20180805214457/http://www.fluxbox.org/docbook/en/html/screenshots/)). The same capture describes the project as "licensed under the MIT-License".
- **r/unixporn**: a GummySearch snapshot of 669k members lists the top topics as Hyprland, Rice, KDE, i3, bspwm, Plasma, OC, GNOME, Xfce and SwayFX. Fluxbox is absent from the list ([GummySearch](https://gummysearch.com/r/unixporn)). The capture date is not shown.

### 2b. Example threads and pages

| Link | When | What it shows |
|---|---|---|
| [Arch Desktop Screenshots, pid 86645](https://bbs.archlinux.org/viewtopic.php?pid=86645) | about May 2005 | "fluxbox-devel with idesk and torsmo" (credits a torsmorc idea). Thread is the closed monthly sticky. |
| [December 2005 Arch Screenshots, pid 126494](https://bbs.archlinux.org/viewtopic.php?pid=126494) | 2005-12-01 onward | Fluxbox with panbox and urxvt; Fluxbox with Serbian Frost, adesklets and conky; a guessed "gkrellm2 on the right, torsmo/conky in the bottom corners, iDesk" that was confirmed except urxvt in place of aterm |
| [FreeBSD forums, "Screenshots"](https://forums.freebsd.org/threads/screenshots.412/) | 2008-11-20 | Fluxbox-1.1.0.1_2 with aterm, zsh, scrot, torsmo and mplayer |
| [Pling: fluxbox-ubuntu](https://www.pling.com/p/1126291) | 2008-06-05 | Screenshot entry by trashbox; 41 downloads |
| [Pling: Debian Fluxbox](https://www.pling.com/p/1126279) | 2008-06-01 | Screenshot entry by cagwait |
| [Pling: ax_fluxbox](https://www.pling.com/p/1126287) | 2009-09-20 | Screenshot entry by aimara |
| [Pling: ArchFlux](https://www.pling.com/p/1126242) | 2010-02-27 | Screenshot entry by Shinryuu |
| [Pling: Conkymania updated](https://www.pling.com/p/1126289) | 2010-08-10 | Window-manager screenshot by flatcat; the title suggests conky |
| [MX Linux "MX Fluxbox Screenshots"](https://www.forum.mxlinux.org/viewtopic.php?p=641223) | not checked | Snippet only. A tint2 bottom bar and custom executors. Not opened: the site returned 403 |
| [BunsenLabs post, 2015](https://forums.bunsenlabs.org/viewtopic.php?pid=5313) | 2015-10-29 | Recommends box-look, customize.org and tenr.de for styles |

Pling screenshot entries (11 Fluxbox Screenshots and 9 Window-Manager Screenshots) cluster in 2007-2010, with a few in 2004 and 2011-2014.

### 2c. Recurring desktop recipes

The most consistent recipe is the one in the 2005-2008 threads: a plain Fluxbox style, a transparent terminal, torsmo or conky for stats, iDesk for icons, and gkrellm or other dockapps on one edge. Evidence per element:

- **Conky or torsmo corner stats:** in the May 2005, December 2005 and 2008 threads above.
- **iDesk icons:** the May 2005 thread, and the December 2005 thread's guess. The [fluxbox-wiki iDesk how-to](https://web.archive.org/web/20160627023452/http://fluxbox-wiki.org:80/category/howtos/en/Idesk.html) describes it as an app that "shows icons on the desktop". Its successor, [fixxxer/idesk-ng](https://github.com/fixxxer/idesk-ng) (BSD-3-Clause, pushed 2026-10-09), is still maintained.
- **Pseudo-transparent terminal:** aterm in the 2008 FreeBSD thread. The December 2005 thread guessed a transparent aterm, and its poster used urxvt. The Pling entry "Cyanized" sets "Menu alpha value: 120" ([Pling](https://www.pling.com/p/1016958)).
- **gkrellm and dockapps:** gkrellm2 on the right edge in December 2005. For the slit, [markusfisch/bbdock](https://github.com/markusfisch/bbdock) (Unlicense, 2019) draws transparent PNG icons, and Fluxbox is among the targets. The wmclock, wmCalClock, wmcpuload, wmnd and wmsystemtray set named in the project brief was not seen in the threads opened.
- **Toolbar:** the fluxbox-wiki [toolbar customisation](https://web.archive.org/web/20150422214105/http://fluxbox-wiki.org:80/category/howtos/en/Toolbar_customization.html) explains removing the prev/next arrows by editing `session.screen0.toolbar.tools`. Toolbar placement was not established from the threads.
- **Fonts:** Artwiz-aleczapka was distributed from fluxbox.org as a separate bitmap-font pack. Their README gives install steps and "LICENSE GPL-2" ([README, 2003](https://web.archive.org/web/20030812182107/http://fluxbox.org:80/artwiz-aleczapka/README)). Shipped styles name X core fonts (lucidasans, lucidatypewriter), LemonSpace needs the Snap font from the Artwiz pack, and Meta needs glisp, all per the style headers above. The fluxbox-wiki [font how-to](https://web.archive.org/web/20160630003643/http://fluxbox-wiki.org/category/howtos/en/Install_fonts.html) points to Fluxmod.
- **GTK pairing:** the fluxbox-wiki [GTK how-to](https://web.archive.org/web/20141130164338/http://fluxbox-wiki.org:80/category/howtos/en/Using_gtk_themes.html) has users unpack GTK themes into `~/.themes`. The AUR mint-x, numix and Pling Adwaita/Numix ports (section 1b) follow the same pattern.
- **Audio:** audacious in the December 2005 thread.

## 3. Dotfiles on GitHub

Star counts, push dates and licences are from the GitHub API on 2026-10-18. Ordered by relevance to the look, not by stars.

| Repo | Stars | Last push | Licence | What is interesting |
|---|---|---|---|---|
| [s3rvac/dotfiles](https://github.com/s3rvac/dotfiles) | 76 | 2026-10-16 | MIT | `fluxbox/.fluxbox` with `scripts/` for lock screen, laser pointer, half-screen moves, dropdown terminal, focus-nth-window, keyboard backlight |
| [addy-dclxvi/debian-openbox-fluxbox-dotfiles](https://github.com/addy-dclxvi/debian-openbox-fluxbox-dotfiles) | 199 | 2026-10-16 | none | `.fluxbox` with `styles/nila` pixmaps, slitlist and overlay, plus GTK, Thunar and dunst configs |
| [addy-dclxvi/gtk-theme-collections](https://github.com/addy-dclxvi/gtk-theme-collections) | 738 | 2018-12-15 | GPL-3.0 | GTK themes as companions to the author's Xfwm, Openbox and Fluxbox themes |
| [ecliptik/fluxland](https://github.com/ecliptik/fluxland) | 17 | 2026-03-04 | MIT | Wayland compositor that reads Fluxbox config and styles. Its `docs/screenshots/styles` shows at least 22 styles |
| [xexpanderx/Fluxbox-themes](https://github.com/xexpanderx/Fluxbox-themes) | 166 | 2020-11-27 | none | Style collection, see section 1d |
| [BlackArch/blackarch-config-fluxbox](https://github.com/BlackArch/blackarch-config-fluxbox) | 16 | 2023-03-14 | none | `usr/share/fluxbox` config with translated menus |
| [archcraft-os/archcraft-fluxbox](https://github.com/archcraft-os/archcraft-fluxbox) | 5 | 2026-08-24 | GPL-3.0 | Archcraft's Fluxbox edition |
| [MX-Linux/mx-fluxbox](https://github.com/MX-Linux/mx-fluxbox) | 4 | 2026-07-08 | GPL-3.0 | `/etc/skel/.fluxbox` for MX and Pi variants, with a styles folder |
| [VoidLinuxBR/voidbr-fluxbox-config](https://github.com/VoidLinuxBR/voidbr-fluxbox-config) | 0 | 2026-10-13 | MIT | Skeleton config for the VoidBR Fluxbox meta package |
| [Tesellium/HopeBox](https://github.com/Tesellium/HopeBox) | 0 | 2026-04-12 | none | Personal dotfiles |
| [kikadf/fluxbox-mod](https://github.com/kikadf/fluxbox-mod) | 0 | 2026-08-21 | none | Configs and theme |
| [felipefacundes/dotfiles](https://github.com/felipefacundes/dotfiles) | 18 | 2025-03-21 | none | Multi-WM set (dwm, i3, Sway, Openbox, Fluxbox) |
| [loochao/fluxbox-dotfiles](https://github.com/loochao/fluxbox-dotfiles) | 1 | 2020-10-21 | none | Backup |
| [leukipp/cortile](https://github.com/leukipp/cortile) | 770 | 2026-10-15 | MIT | Not a dotfile repo. Auto-tiling helper for Openbox, Fluxbox and others |

Excluded: siduck/dotfiles (962 stars) matched the search, but its tree contains no Fluxbox config files.

### Keybinding conventions beyond the defaults

The defaults in [data/keys](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/keys) bind workspace switching to Control+F1-F4 and window cycling to Mod1 Tab ([sibling report, section 3.10](01-fluxbox-features.md)). The dotfiles above converge on these:

- **Super (Mod4) for apps and workspaces.** Mod4 Return opens a terminal. Mod4 1-9 switches workspace and Mod4 Shift 1-9 sends a window there in fluxland; addy uses 1-4 ([addy](https://github.com/addy-dclxvi/debian-openbox-fluxbox-dotfiles/blob/master/.fluxbox/keys), [fluxland](https://github.com/ecliptik/fluxland/blob/main/data/keys)). s3rvac uses Mod4 F1-F8 instead ([keys](https://github.com/s3rvac/dotfiles/blob/master/fluxbox/.fluxbox/keys)).
- **Alt-Tab with groups.** `Mod1 Tab :NextWindow {groups} (workspace=[current])` appears in addy, s3rvac and BlackArch, and is the default too.
- **Super-letter window actions.** addy binds Mod4 C to close, Mod4 F to maximise, Mod4 Z to minimise, Mod4 T to toggle decorations and Mod4 A to centre. fluxland uses the same idea with Mod4 Shift q to close and Mod4 m to maximise.
- **Half-screen and tiling.** fluxland binds Mod4 Left and Right to half-screen. s3rvac uses Alt F7 and F8 with scripts. fluxland also has ArrangeWindows and CascadeWindows.
- **Print for screenshots.** addy uses Print for screeny, with Alt+Print and Control+Print variants. s3rvac uses spectacle and flameshot.
- **Media keys.** XF86Audio keys drive mpc, pulsevol or amixer ([addy](https://github.com/addy-dclxvi/debian-openbox-fluxbox-dotfiles/blob/master/.fluxbox/keys), [BlackArch](https://github.com/BlackArch/blackarch-config-fluxbox/blob/master/usr/share/fluxbox/keys)).
- **Scripts as bindings.** s3rvac binds keys to `~/.fluxbox/scripts/*.sh`, so each binding is a file.
- **Mouse.** Scrolling the desktop switches workspace in BlackArch. addy scrolls the titlebar to shade and unshade.

## 4. Licensing

| Item | Licence statement | Source | Reuse verdict |
|---|---|---|---|
| Fluxbox code and COPYING | MIT, "Copyright (c) 2001-2011 The Fluxbox Team", with a Blackbox "Copyright (c) 1997 - 2000 Brad Hughes" notice | [COPYING](https://github.com/fluxbox/fluxbox/blob/master/COPYING) | Clear |
| 16 styles without per-file licence (Artwiz, BlueNight, Flux, LemonSpace, Makro, MerleyKay, Meta, Nyz, Operation, Outcomes, Results, Shade, Twice, qnx-photon, BlueFlux, Emerge) | None in file; some carry author names | file headers above | Inherits MIT via the tree, but no author has declared it. Keep author lines; reuse parameters |
| 11 tenner directories (arch, bloe, bora_*, carp, green_tea, ostrich, zimek_*) | CC BY-SA 3.0 (de) in each header | [arch](https://github.com/fluxbox/fluxbox/blob/master/data/styles/arch/theme.cfg) | Share-alike. Cannot be relicensed to MIT inside the tree. Attribution and share-alike apply |
| tenr.de collection | CC BY-SA 3.0 Germany ([about](https://web.archive.org/web/20161018231550/http://tenr.de/about/)). Fedora says CC BY-SA 2.5. Gentoo says GPL-2 | repoview and Gentoo links above | Conflicting metadata. Use CC BY-SA 3.0 as the default reading |
| Artwiz-aleczapka fonts | "LICENSE GPL-2" ([README](https://web.archive.org/web/20030812182107/http://fluxbox.org:80/artwiz-aleczapka/README)). artwiz-fonts-wl is GPL-2.0 ([GitHub](https://github.com/whitelynx/artwiz-fonts-wl)) | README, GitHub API | GPL-2. The original Artwiz design licence was not checked |
| Terminus | "Terminus Font is licensed under the SIL Open Font License, Version 1.1." Build scripts GPL-2.0 or later ([homepage](https://terminus-font.sourceforge.net/)). Reserved name "Terminus Font" ([Debian copyright, search snippet](https://metadata.ftp-master.debian.org/changelogs//main/x/xfonts-terminus/xfonts-terminus_4.48-3_copyright)) | homepage | OFL. Bundle freely. Derivatives may not use the reserved name |
| ProggyClean | MIT, Tristan Grimmer, 2004-2005 ([Qt docs](https://doc.qt.io/qt/qt3d-attribution-imgui-proggyclean.html), secondary) | Qt docs | MIT, secondary source only |
| X core fonts (lucidasans, lucidatypewriter) | Not checked | style files | Avoid bundling. Substitute Terminus |
| Pling items | Self-declared tags. 11 of top 30 declare a licence. 19 declare none | [OCS detail API](https://api.pling.com/ocs/v1/content/data/1016958?format=json) | Undeclared is all rights reserved. Use only the tagged ones |
| GitHub dotfiles and style repos | No LICENSE file on 15 of the 25 repos in sections 1d and 3 | repo metadata | Read-only inspiration |

Clean to reuse:

- MIT: [s3rvac/dotfiles](https://github.com/s3rvac/dotfiles), [ecliptik/fluxland](https://github.com/ecliptik/fluxland), [VoidLinuxBR config](https://github.com/VoidLinuxBR/voidbr-fluxbox-config), [leukipp/cortile](https://github.com/leukipp/cortile), Pling Cyanized, Milly and Unicorn (tagged mit-license).
- MIT font: ProggyClean (secondary source).
- BSD-3: [idesk-ng](https://github.com/fixxxer/idesk-ng).
- Unlicense: [bbdock](https://github.com/markusfisch/bbdock).

Copyleft (GPL), usable only if the project accepts GPL: corebob styles and the AUR packages from them ([GPL-3.0](https://github.com/bytting/fluxbox-styles-corebob)), [son-link/fluxbox-arc-dark](https://github.com/son-link/fluxbox-arc-dark) (GPL-3.0), [archcraft-fluxbox](https://github.com/archcraft-os/archcraft-fluxbox) (GPL-3.0), [MX fluxbox](https://github.com/MX-Linux/mx-fluxbox) (GPL-3.0), [trizen/fbmenugen](https://github.com/trizen/fbmenugen) (GPL-3.0).

Avoid: undeclared community styles (most of section 1b's untagged entries and section 1d's "none" repos), and the MX/antiX collection, whose README says upstream comments must be checked per file ([wachin README](https://github.com/wachin/fluxbox-styles-themes--from-MX-Linux-antiX-23)).

## 5. Converters and ports

- **fbox2obox**: not found. Name search returned nothing, and GitHub repo searches for fluxbox2openbox and fbtoobox returned nothing.
- **Openbox themeupdate.py** (GPL-2, Dana Jansens): "for updating old themes from Blackbox, Fluxbox, and Openbox2 to Openbox3" ([source](https://github.com/danakj/openbox/blob/master/tools/themeupdate/themeupdate.py)). Fluxbox to Openbox 3 is the stated direction.
- **ob-2-fb** (BSD, SourceForge): "a script written in Python that can convert Openbox 3 themes to Fluxbox themes" ([project](https://sourceforge.net/p/ob2fb/)). The reverse direction.
- **Openbox ports of Fluxbox styles** (search snippets, not opened): Color Me Bad by Rydgel ([KDE Store](https://store.kde.org/p/1017057)), Eco Green Olive ([KDE Store](https://store.kde.org/p/1017345)), and a KDE Store near-port of Nooto, probably [store.kde.org/p/1017194](https://store.kde.org/p/1017194).
- **Fluxbox menu generator**: [trizen/fbmenugen](https://github.com/trizen/fbmenugen) (GPL-3.0, 17 stars, pushed 2023-10-17), with icon support.
- **Fluxbox to GTK or Qt colours**: no converter found. Manual GTK editing with a colour picker is the documented route ([Linux.com, search snippet](https://www.linux.com/?p=503274)). Converters found run the other way (KDE3 and Qt3 schemes to Fluxbox, [Falkon store, snippet](https://store.falkon.org/u/DDZ/morecomments/page/2)).
- **labwc target**: [labwc-theme(5)](https://github.com/labwc/labwc/blob/master/docs/labwc-theme.5.scd) defines textures as Solid or Gradient with Vertical or SplitVertical types. Fluxbox's Raised, Flat, Bevel, Interlaced, Diagonal and CrossDiagonal modifiers have no labwc equivalent. A converter has to drop or approximate them. Styles whose titles are a vertical gradient (Meta, MerleyKay, Artwiz, qnx-photon, Makro) map to Gradient Vertical once the Raised, Flat and Sunken modifiers are dropped. Diagonal, bevel and interlaced styles (Results, Outcomes, Nyz, Twice) do not map.
- **Prior art on Wayland**: [fluxland](https://github.com/ecliptik/fluxland) says Fluxbox style files "work directly" with texture syntax "preserved" ([migration section](https://github.com/ecliptik/fluxland/blob/main/README.md)). It is the closest existing parser and renderer, though it targets wlroots, not labwc.

## Gaps and next checks

- Dockapps beyond gkrellm and bbdock were not seen in threads. The slit set in the brief is unconfirmed as a 2005-2008 norm.
- MX forum thread and Gentoo 2003 thread not opened.
- The original Artwiz font licence (upstream, not the 2003 README) is unverified.
- The Lucida X core font licence is unverified.
- Whether labwc supports any texture beyond Vertical and SplitVertical gradients should be checked against its source, not only its manual.
