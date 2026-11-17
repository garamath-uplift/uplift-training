#!/bin/bash
# Uplift module tools for Mac and Linux. Double-click in Finder for a menu, or run:  tools/module.command <command> <module>
# Needs PowerShell 7 (pwsh). It installs into your home folder without admin rights; see tools/README.md.
here="$(cd "$(dirname "$0")" && pwd)"
if ! command -v pwsh >/dev/null 2>&1; then
  echo "PowerShell 7 (pwsh) isn't installed yet. To install it without admin rights:"
  echo "  1. Download the .tar.gz for your Mac (osx-arm64 for Apple silicon, osx-x64 for Intel) from"
  echo "     https://github.com/PowerShell/PowerShell/releases/latest"
  echo "  2. Run:  mkdir -p ~/powershell && tar -xzf ~/Downloads/powershell-*.tar.gz -C ~/powershell"
  echo "           chmod +x ~/powershell/pwsh && mkdir -p ~/bin && ln -sf ~/powershell/pwsh ~/bin/pwsh"
  echo "  3. Make sure ~/bin is on your PATH (add  export PATH=\"\$HOME/bin:\$PATH\"  to ~/.zshrc), then open a new Terminal."
  echo "Or skip this: GitHub runs the same checks on every pull request."
  [ $# -eq 0 ] && read -r -p "Press Return to close. "
  exit 2
fi
if [ $# -eq 0 ]; then
  pwsh -NoProfile -File "$here/module.ps1" menu
  rc=$?
  read -r -p "Press Return to close. "
  exit $rc
fi
pwsh -NoProfile -File "$here/module.ps1" "$@"
