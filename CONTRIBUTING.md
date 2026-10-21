# Contributing to kflux

Thanks for helping. kflux is maintained by one person, so small, focused
changes that come with evidence they work get merged fastest.

## Reporting bugs and asking for features

Use the [issue templates](https://github.com/endthestart/kflux/issues/new/choose).
For a bug, include the output of `kflux doctor` and `kflux warnings`, your
distro, and whether you run stock `labwc` or `labwc-kflux`. Security problems
go through [SECURITY.md](SECURITY.md), not public issues.

Issues are triaged within a week. Issues labelled `needs-info` are closed after
30 days without a reply; reopen them when you have the details.

## Supported platforms

Arch Linux and CachyOS ([ADR 0005](docs/adr/0005-supported-platforms.md)).
Fixes for other distros are welcome when they don't complicate the supported
ones.

## Making a change

1. Open an issue first for anything bigger than a bug fix, so we can agree on
   the approach before you write it.
2. Keep kflux working on **stock labwc**. Anything that needs labwc changes
   belongs in `patches/labwc-tabs.patch` and must degrade to a
   `kflux warnings` entry without it ([ADR 0003](docs/adr/0003-tabs-as-optional-labwc-patch.md)).
3. The translator (`src/kflux`) uses Python's standard library only.
4. Run `make check`. For changes to the session or translator, test in the VM:
   [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) has the image build, `tools/verify.sh`
   and the dev loop.
5. Add a line under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md) for
   anything a user would notice.
6. Commit messages: a short subject line, a blank line, then at most one short
   paragraph on what changed and why.

## Sign-off (DCO)

Every commit must be signed off under the
[Developer Certificate of Origin](https://developercertificate.org/): you
certify that you wrote the change, or otherwise have the right to submit it
under the project's licence. Sign off with `git commit -s`, which adds:

```
Signed-off-by: Your Name <you@example.com>
```

Use your real name or a consistent identity. Changes to
`patches/labwc-tabs.patch` are GPL-2.0-only, like labwc; everything else is
MIT.

## AI-assisted contributions

kflux is itself built with AI assistance, and AI-assisted contributions are
welcome ([ADR 0006](docs/adr/0006-ai-assisted-contributions.md)). No
disclosure trailer is required. The rule for every contribution, however it
was written:

- **a human has built it, run it, and can explain it.** You answer review
  questions about your change yourself.
- Don't send kflux-derived AI-generated content to projects that ban it.
  labwc does; that's why the tabs patch isn't offered upstream.

## Code of conduct

Everyone taking part follows the [code of conduct](CODE_OF_CONDUCT.md). Conduct reports go through GitHub, as it describes.
