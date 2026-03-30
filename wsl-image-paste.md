# WSL image paste (`Alt+V`)

This note documents a WSL-specific image paste failure I hit in Codex CLI and the local patch that fixed it.

## Symptom

On WSL, pressing `Alt+V` in Codex to paste an image from the clipboard failed with:

```text
Failed to paste image: no image on clipboard: The clipboard contents were not available in the requested format or the clipboard is empty.
```

This happened even when the Windows clipboard clearly contained an image.

## Repro

On this machine, putting an image on the Windows clipboard made WSL expose:

```text
image/bmp
```

The important part was that Codex did enter its WSL fallback path, but still rejected the pasted image.

## Root cause

The WSL clipboard fallback in Codex calls PowerShell to dump the clipboard image to a temporary PNG, then maps the returned path into WSL.

The original code assumed PowerShell would always print a Windows path like:

```text
C:\Users\cong\AppData\Local\Temp\...
```

But on this setup, PowerShell could return a Unix-style absolute path like:

```text
/tmp/...
```

When that happened, Codex tried to convert the path as if it were a Windows path, failed the conversion, and reported `no image on clipboard`.

## Local patch

The local fix was simple:

- accept an already-absolute Unix path from the WSL fallback
- only run Windows-path conversion when the returned path is not already a valid absolute Unix path

In the Codex source, this means the WSL fallback should normalize both:

- absolute Unix paths like `/tmp/example.png`
- Windows paths like `C:\Users\...\example.png`

There is also a small test for the Unix-path case.

## Status

This is a local patch first. The right long-term fix is to send it upstream as a small PR against Codex CLI.

That is the preferred order:

1. send the fix upstream
2. keep this note in the WSL setup repo as documentation

## Local caveat

My temporary local launcher patch points `codex` on WSL to a custom built binary in `~/.local/share/codex-wsl-patched/codex`.

That is only a stopgap for daily use while waiting for an upstream fix. A future `npm install -g @openai/codex` can overwrite related files, so this should not be treated as the final solution.
