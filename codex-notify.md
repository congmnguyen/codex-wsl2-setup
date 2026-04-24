# WSL "Done" notification for Codex

This note documents a simple Windows notification setup for Codex CLI running inside WSL2.

## Problem

When Codex finishes a long turn in WSL, the terminal does not give a strong visual signal that the turn is done.

That is easy to miss if Windows Terminal is in the background while Codex is still working.

## Approach

Use Codex's external `notify` command to launch a small WSL shell script.

That script calls Windows PowerShell directly and shows a Windows balloon notification, but only when Windows Terminal is not already the foreground window.

The result is:

- no popup if you are already looking at the terminal
- a tray balloon when Codex finishes in the background
- clicking the balloon restores and focuses Windows Terminal

## Script

Save this as `~/bin/codex-notify`:

```bash
#!/bin/bash

if [[ "${1:-}" == \{* ]]; then
    case "$1" in
        *'"type":"agent-turn-complete"'*|*'"type": "agent-turn-complete"'*)
            title="Codex"
            message="Done!"
            ;;
        *)
            exit 0
            ;;
    esac
else
    title="${1:-Codex}"
    message="${2:-Notification}"
fi

title=$(echo "$title" | sed 's/"/\\"/g')
message=$(echo "$message" | sed 's/"/\\"/g')

/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport(\"user32.dll\")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport(\"user32.dll\")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport(\"user32.dll\")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport(\"user32.dll\")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@
\$hwnd = [Win32]::GetForegroundWindow()
\$winPid = 0
[Win32]::GetWindowThreadProcessId(\$hwnd, [ref]\$winPid) | Out-Null
\$proc = Get-Process -Id \$winPid -ErrorAction SilentlyContinue
if (\$proc -and \$proc.Name -eq 'WindowsTerminal') { exit 0 }

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
\$notification = New-Object System.Windows.Forms.NotifyIcon
\$notification.Icon = [System.Drawing.SystemIcons]::Information
\$notification.BalloonTipTitle = '$title'
\$notification.BalloonTipText = '$message'
\$notification.Visible = \$true

\$notification.add_BalloonTipClicked({
    \$wt = Get-Process -Name 'WindowsTerminal' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (\$wt -and \$wt.MainWindowHandle -ne [IntPtr]::Zero) {
        [Win32]::ShowWindow(\$wt.MainWindowHandle, 9) | Out-Null
        [Win32]::SetForegroundWindow(\$wt.MainWindowHandle) | Out-Null
    }
    [System.Windows.Forms.Application]::Exit()
})
\$notification.add_BalloonTipClosed({
    [System.Windows.Forms.Application]::Exit()
})

\$notification.ShowBalloonTip(5000)
[System.Windows.Forms.Application]::Run()
\$notification.Dispose()
"
```

Make it executable:

```bash
chmod +x ~/bin/codex-notify
```

## Codex config

Add this to `~/.codex/config.toml`:

```toml
notify = ["bash", "-lc", "~/bin/codex-notify \"$1\" &", "--"]
```

Codex passes one JSON payload argument to the notify command. This script only reacts to `agent-turn-complete` and ignores other notification types.

The trailing `&` matters. The PowerShell process stays alive while the balloon is visible, so the notification script should be detached immediately instead of blocking Codex.

## Why `notify` and not `tui.notifications`

Codex has built-in terminal notifications too:

```toml
[tui]
notifications = true
notification_method = "auto"
```

That is useful for terminal bell / OSC 9 support, but `notify` is the right mechanism when you want a custom external notifier on WSL that can call Windows PowerShell directly.

## Result

When Codex completes a turn and Windows Terminal is not focused, Windows shows a tray balloon with:

- title: `Codex`
- message: `Done!`

Clicking the balloon restores and focuses Windows Terminal.

## Troubleshooting

**No notification appears**

- Confirm the script exists: `ls -l ~/bin/codex-notify`
- Test manually: `~/bin/codex-notify "Test" "Hello"`
- Confirm `notify = [...]` is present in `~/.codex/config.toml`
- Check Windows notification settings and Focus Assist

**Codex feels blocked after the turn ends**

- Make sure the config uses `bash -lc` and ends with `&`

**Clicking the balloon does not focus Windows Terminal**

- Windows sometimes restricts focus stealing
- In practice this usually works because the action is triggered by your click on the balloon itself
