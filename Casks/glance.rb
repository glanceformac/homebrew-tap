cask "glance" do
  version "1.0.0"
  sha256 "14f1ac6e5c27c3b5a0524d0ce6703a9d9ae87030f943fa72c7b589713824ba60"

  url "https://github.com/glanceformac/glance/releases/download/v#{version}/Glance.zip"
  name "Glance for Mac"
  desc "Notch and menu bar island with media, Cinema mode, Teleprompter and Claude Code"
  homepage "https://github.com/glanceformac/glance"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Glance.app"

  # The app is ad-hoc signed, not notarised (no paid Apple Developer account), so remove the
  # download quarantine flag from Glance.app only. Then connect the Chrome extension.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Glance.app"],
                   must_succeed: false
    system_command "#{appdir}/Glance.app/Contents/Resources/install-chrome-host.sh",
                   env:          { "GLANCE_APP" => "#{appdir}/Glance.app" },
                   must_succeed: false
  end

  uninstall_preflight do
    system_command "#{appdir}/Glance.app/Contents/Resources/install-chrome-host.sh",
                   args:         ["--uninstall"],
                   env:          { "GLANCE_APP" => "#{appdir}/Glance.app" },
                   must_succeed: false
  end

  uninstall quit: "app.glanceformac.glance"

  zap trash: [
    "~/Library/Application Support/Glance",
    "~/Library/Caches/Glance",
    "~/Library/Preferences/app.glanceformac.glance.plist",
  ]

  caveats <<~EOS
    Cinema mode needs the Glance Chrome extension. In chrome://extensions turn on
    Developer mode, click Load unpacked and choose:
      ~/Library/Application Support/Glance/Chrome Extension

    Claude Code hooks are optional. See:
      https://github.com/glanceformac/glance/blob/main/INSTALL-HOOKS.md
  EOS
end
