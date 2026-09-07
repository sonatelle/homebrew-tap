# Sonatelle Homebrew Tap

Homebrew packages for Sonatelle's macOS applications.

## Install

```sh
brew install --cask sonatelle/tap/rondo
```

The fully qualified name taps this repository on the way past, so there is
no need to `brew tap sonatelle/tap` first.

## What is here

- **[Rondo](https://github.com/sonatelle/rondo)** - a subscription tracker
  that keeps its data in a local SQLite file and talks to nobody. Apple
  Silicon, macOS 14 or later.

## What installing waives

Rondo is ad-hoc signed and not notarized. Signing it properly needs a paid
Apple Developer ID, which the project does not have.

Homebrew quarantines what it downloads, and the `--no-quarantine` flag that
used to be the answer was removed in Homebrew 5.1. Left alone, this cask
would install an app that then refuses to open. So the cask clears the
quarantine attribute from the bundle it just installed.

Said plainly: **installing from this tap waives Gatekeeper's check for that
one app.** It is the same trust you would extend by opening the disk image
and confirming the warning by hand - only made once, in advance, without
being asked. That is worth knowing before you type the command.

If you would rather make that decision yourself, take the disk image from
[Rondo's releases](https://github.com/sonatelle/rondo/releases/latest) and
open it the usual way.

## License

MIT. See [LICENSE](LICENSE).
