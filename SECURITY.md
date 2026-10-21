# Security policy

## Reporting a vulnerability

Report vulnerabilities privately through GitHub:
[Report a vulnerability](https://github.com/endthestart/kflux/security/advisories/new)
(the repository's Security tab). Please don't open a public issue.

Include what you found, how to reproduce it, the kflux version (`kflux version`
or `pacman -Q kflux`) and whether `labwc-kflux` is installed.

## What to expect

- An acknowledgement within **7 days**.
- A fix, or advice on how to mitigate the problem, within **90 days**. We'll
  agree a disclosure date with you and credit you in the advisory unless you
  prefer not to be named.

## Supported versions

| Version | Security fixes |
|---|---|
| the current minor release | yes |
| the previous minor release | for 3 months after its successor ships |
| older | no |

## Scope

kflux runs the commands in your own config files by design: `[exec]` lines and
pipe menus in `menu`, the `startup` file and `apps` rules. That's not a
vulnerability. Things that are in scope include the translator writing outside
`~/.config` or `~/.cache`, a crafted style or config file making kflux run
something it didn't name, unsafe temporary files, and problems in the
`labwc-kflux` patch. Vulnerabilities in labwc, Waybar or KDE themselves go to
those projects.
