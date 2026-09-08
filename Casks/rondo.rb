cask "rondo" do
  version "0.5.0"
  sha256 "2bde4e818d879b46ae1159e441850d08f4f28429cf1f0c005f420770c51e28b4"

  url "https://github.com/sonatelle/rondo/releases/download/v#{version}/Rondo-#{version}.dmg"
  name "Rondo"
  desc "Subscription tracker with a local SQLite store"
  homepage "https://github.com/sonatelle/rondo"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Both come from apple/project.yml in rondo: ARCHS is arm64 and the
  # deployment target is macOS 14.0. Without these the cask would happily
  # install, onto machines that cannot run what it installed.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Rondo.app"

  # Rondo is ad-hoc signed and not notarized, and Homebrew quarantines what it
  # downloads - the --no-quarantine flag users once reached for was removed in
  # Homebrew 5.1. Left alone, this cask would install an app that then refuses
  # to open. Clearing the attribute is how it opens, and it is worth naming
  # plainly: it waives Gatekeeper's check for this one bundle. The README says
  # so too, rather than leaving it to be found out.
  #
  # {{appdir}} rather than a literal /Applications: step arguments are expanded
  # at run time, so this still lands on the right bundle for anyone who set
  # --appdir. And -d com.apple.quarantine removes the one attribute that is in
  # the way, where -c would clear every extended attribute the bundle carries.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/Rondo.app"],
        writable_paths: ["Rondo.app"],
        writable_base:  :appdir
  end

  # The menu bar item keeps the process alive with no window open, so an
  # uninstall left to itself would replace the bundle under a running app.
  uninstall quit: "com.sonatelle.rondo"

  zap trash: [
    # Where an unsandboxed build puts the database, which is what a developer
    # running one from Xcode would be left with.
    "~/Library/Application Support/Rondo",
    # The app is sandboxed, so the database and the preferences are both
    # inside the container rather than in the usual two places.
    "~/Library/Containers/com.sonatelle.rondo",
  ]
end
