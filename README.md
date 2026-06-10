# Personal CRM MCP

Operator setup for the Personal CRM intake MCP on the Clawdbot Mac mini.

Use this when you want Codex, Claude Code, Cursor, or GitHub Copilot to submit a CSV, Lu.ma link, or Brella link into the Personal CRM pipeline without cloning the private pipeline repo or running local commands.

MCP endpoint:

```text
https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp
```

## Install By OS

Before starting, make sure:

1. You are already connected to the right tailnet.
2. Codex, Claude Code, Cursor, or another MCP-capable app is installed.

### macOS

Download this repo:

```bash
git clone https://github.com/zabrodsk/personal-crm-mcp.git
cd personal-crm-mcp
```

No `git`: open `https://github.com/zabrodsk/personal-crm-mcp`, download the ZIP, unzip it, and open Terminal in the unzipped folder.

Install for Codex. This adds the MCP and installs the bundled `$start-crm-pipeline` skill:

```bash
bash scripts/install-codex.sh
```

Add the MCP to Claude Code:

```bash
claude mcp add --transport http --scope user personal-crm-intake https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp
```

Then run `/mcp` inside Claude Code and confirm `personal-crm-intake` is connected.

### Linux

Download this repo:

```bash
git clone https://github.com/zabrodsk/personal-crm-mcp.git
cd personal-crm-mcp
```

No `git`: open `https://github.com/zabrodsk/personal-crm-mcp`, download the ZIP, unzip it, and open a terminal in the unzipped folder.

Install for Codex. This adds the MCP and installs the bundled `$start-crm-pipeline` skill:

```bash
bash scripts/install-codex.sh
```

Add the MCP to Claude Code:

```bash
claude mcp add --transport http --scope user personal-crm-intake https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp
```

### Windows

Download this repo first:

```powershell
git clone https://github.com/zabrodsk/personal-crm-mcp.git
cd personal-crm-mcp
```

If you do not use `git`, open `https://github.com/zabrodsk/personal-crm-mcp`, download the ZIP, unzip it, and open PowerShell in the unzipped folder.

Install for Codex. This adds the MCP and installs the bundled `$start-crm-pipeline` skill:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-codex.ps1
```

Add the MCP to Claude Code:

```powershell
claude mcp add --transport http --scope user personal-crm-intake https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp
```

To install only the Codex skill without changing MCP config:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-codex-skill.ps1
```

## Use The Skill

After installing the skill, call it in Codex with `$start-crm-pipeline`.

Submit an attached CSV:

```text
Use $start-crm-pipeline with the attached CSV. Event name: SaaStr 2026.
```

Submit a Lu.ma event:

```text
Use $start-crm-pipeline for this Lu.ma event: https://lu.ma/... Event name: AI Founder Dinner.
```

Submit a Brella event:

```text
Use $start-crm-pipeline for this Brella event: https://panathenea.brella.io/events/... Event name: Panathenea.
```

Check status:

```text
Use $start-crm-pipeline to check the Personal CRM run status for SaaStr 2026.
```

## What The MCP Does

The MCP exposes these tools:

- `submit_csv_intake`
- `submit_luma_intake`
- `submit_brella_intake`
- `get_intake_status`

The Clawdbot Mac mini validates the input, stages a run, starts the full Personal CRM pipeline, writes intake/export metadata, and returns run status. Operators should not run Python, Docker, Postgres, `make`, or local pipeline commands.

## Troubleshooting

If the MCP is missing or disconnected:

1. Confirm you are connected to the right tailnet.
2. Re-run `scripts/install-codex.sh`, `scripts/install-codex.ps1`, or the Claude MCP add command for your AI app.
3. In Claude Code, run `/mcp`.
4. In Codex, run `codex mcp list`.

If a CSV is rejected, use a UTF-8 CSV under 25 MB with headers and at least one data row.

If a Lu.ma or Brella URL is rejected, use the original event URL from the supported host.

If a run fails, ask a maintainer to inspect the `log_path` returned by `get_intake_status`.
