# Sonatelle Tap Agent Guide

This repository is the Homebrew tap for Sonatelle's macOS applications. It
refines the Sonatelle organization conventions; where the two differ, this
file wins here.

The short name is `sonatelle/tap`, which is why the repository has to be
called `homebrew-tap`.

## Do Not Bump Versions By Hand

`version` and `sha256` in `Casks/rondo.rb` are written by
`.github/workflows/tap.yml` in [sonatelle/rondo](https://github.com/sonatelle/rondo),
which runs when a Rondo release is published: it downloads the disk image,
hashes it, and commits the two lines straight to `main`. Editing them here
by hand invites a checksum that was typed rather than computed, and the next
release would overwrite it anyway. Everything else in the cask is edited
here.

That workflow is the one thing allowed to write `main` without a pull
request. It is holding a checksum it computed a moment earlier from the file
it just downloaded, so there is nothing for a reviewer to check that the job
has not already checked; and a release that has been published is one people
can install, which is a poor moment to be waiting on a review. It reads back
both lines after writing them and fails if either did not change.

## Layout

```text
Casks/            *.rb casks, one token per file, basename equal to the token
.github/workflows/ brew test-bot
.githooks/        blocks commits, merges, and pushes on main
```

There are no formulae. Sonatelle's command-line tools would go under
`Formula/`, but nothing is there yet.

## Cask Rules

- Always a real `version` and `sha256`. Never invent a checksum; take it from
  the file, not from a release page's summary.
- `url` and `homepage` are both on github.com, so no `verified:` stanza.
- Say what the app actually requires. Rondo's `depends_on arch: :arm64` and
  `depends_on macos: :sonoma` come from `ARCHS` and the deployment target in
  rondo's `apple/project.yml`; a cask that omitted them would install onto
  machines that cannot run what it installed. Use the symbol form - the
  string comparison `">= :sonoma"` is deprecated and audit rejects it.
- Keep the stanzas in the canonical order and the `zap` list alphabetical.
  `Cask/StanzaOrder` and `Cask/ArrayAlphabetization` both fail the build over
  it, and neither is worth a second CI round.
- Give every cask a `zap`. Sonatelle's apps are sandboxed, so their data is
  under `~/Library/Containers/<bundle id>` rather than in the usual two or
  three places.
- `uninstall quit:` for anything with a menu bar item, which keeps running
  with no window open.

### Clearing Quarantine

Sonatelle's apps are ad-hoc signed and not notarized, and Homebrew always
quarantines what it downloads. A cask without a step that clears the
attribute installs an app that cannot be opened.

```ruby
postflight_steps do
  run "/usr/bin/xattr",
      args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Rondo.app"],
      writable_paths: ["Rondo.app"],
      writable_base:  :appdir
end
```

Three things there are deliberate:

- `postflight_steps`, not a `postflight` block. The `Cask/InstallSteps` cop
  rejects the block form outright now, third-party taps included.
- `{{appdir}}`, not a literal `/Applications`. Step arguments are expanded at
  run time, so this lands on the right bundle for anyone who set `--appdir`.
- `-d com.apple.quarantine`, not `-c`. It removes the one attribute that is
  in the way; `-c` would clear every extended attribute the bundle carries.

This is a real waiver of Gatekeeper's check, made on the user's behalf. The
README says so in as many words; keep it that way.

## Git Workflow

All changes land through a short-lived branch and a pull request; `main` is
never committed to, merged into, or pushed directly by a person or an agent.
The one exception is the version bump described above, which arrives from
rondo's workflow. `.githooks/` enforces this locally - the hooks are not
installed in a CI checkout, which is why the workflow gets past them. After
cloning:

```bash
git config core.hooksPath .githooks
```

Never set `SONATELLE_TAP_ALLOW_MAIN`; it exists for a person handling an
emergency, not for an agent.

Conventional Commits subjects, one intent each, subject line only - no body
and no trailers. Merge on GitHub with **Rebase and merge**, then
`git pull --ff-only`.

## Checks

CI is `brew test-bot --only-tap-syntax`, which is style and audit over the
whole tap. It has to be test-bot rather than `brew style` and `brew audit`
against a path, because Homebrew refuses to look at a cask that is not
inside a tap.

To run the same checks against a working copy:

```bash
brew tap sonatelle/tap "$(git rev-parse --show-toplevel)"
brew style sonatelle/tap
brew audit --cask sonatelle/tap/rondo
brew install --cask --verbose sonatelle/tap/rondo
```

Fix style and audit findings before merge; `HashAlignment`, trailing commas
and deprecated `depends_on macos:` symbols are the usual ones.
