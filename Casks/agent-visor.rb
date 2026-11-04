# frozen_string_literal: true

cask "agent-visor" do
  version "2.9.3"
  sha256 "ef9d8384bca08f0895456fff07552bad223b3a1d9846b52c689e532d7b00f0a0"

  url "https://github.com/824zzy/agent-visor/releases/download/v#{version}/AgentVisor-v#{version}.zip"
  name "Agent Visor"
  desc "Monitor and return to coding-agent sessions from the menu bar"
  homepage "https://github.com/824zzy/agent-visor"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Agent Visor.app"

  # Public releases use the pinned AgentVisor Release certificate. Remove
  # quarantine while preserving the distributed signature so macOS keeps the
  # same Accessibility identity across ordinary updates.
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/Agent Visor.app"]
  end

  # The hook file at ~/.claude/hooks/agent-visor-state.py is deliberately
  # excluded from zap. It lives in Claude Code's shared hooks directory
  # alongside other tools' hooks, and removing it would require surgically
  # editing settings.json which is also shared. Users who want to fully
  # remove the hook should delete the file manually and clean up any
  # agent-visor-state.py entries in ~/.claude/settings.json.
  zap trash: [
    # Staging profile imported once by the cutover.
    "~/Library/Application Support/Agent Visor Next",
    # Stable Electron profile.
    "~/Library/Application Support/Agent Visor",
    # Legacy Swift profile.
    "~/Library/Application Support/agent-visor",
    "~/Library/Caches/com.824zzy.AgentVisor",
    "~/Library/HTTPStorages/com.824zzy.AgentVisor",
    "~/Library/Logs/AgentVisor",
    "~/Library/Preferences/com.824zzy.AgentVisor.plist",
  ]

  caveats <<~EOS
    On macOS 15 Sequoia or later, Agent Visor needs Full Disk Access to read
    coding-agent session transcripts in ~/.claude/projects/, ~/.codex/, and
    ~/.cursor/projects/. Without it the sidebar stays empty with no error.

      System Settings → Privacy & Security → Full Disk Access → add Agent Visor.

    Accessibility is also required (Agent Visor prompts for it on first launch).
  EOS
end
