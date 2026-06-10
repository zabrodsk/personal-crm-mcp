---
name: start-crm-pipeline
description: Project-local Personal CRM operator workflow for starting or checking CSV, Lu.ma, Brella, and Partiful pipeline runs through the connected personal-crm-intake MCP only. Use inside the personal-crm repository when the user says start CRM pipeline, use the MCP, submit an attached CSV or event link, check Personal CRM status, or track a Personal CRM MCP run from Codex, Claude, Cursor, or another MCP-connected agent.
---

# Start CRM Pipeline

Use this skill for operator-facing Personal CRM intake through the official MCP. This is a routing and reporting skill, not a maintainer runbook.

Official MCP URL: `https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp`
Operator-facing endpoint name: `personal-crm-intake` on the Clawdbot Mac mini

## Hard Boundary

- Use only the connected `personal-crm-intake` MCP tools.
- Do not clone the repo, start Docker/Postgres, run Python, invoke `make`, or launch local pipeline commands.
- If the MCP tools are unavailable, stop and tell the user to connect Tailscale and check/add the MCP server. Do not try a local fallback.

Relevant MCP tools:
- `submit_csv_intake`
- `submit_luma_intake`
- `submit_brella_intake`
- `submit_partiful_intake`
- `get_intake_status`

## Workflow

1. Preflight the MCP connection.
   - Confirm the `personal-crm-intake` server or the intake tools are available.
   - If missing, report: connect Tailscale, add/check `personal-crm-intake` at the official MCP URL, then retry.

2. Validate the user input before submitting.
   - Prefer a user-provided `event_name` when present.
   - If `event_name` is missing, infer it without prompting:
     - CSV: derive it from the attached/opened filename.
     - Lu.ma, Brella, or Partiful: derive it from the event URL slug/path.
     - Normalize the inferred name into a readable title by removing extensions, IDs, query strings, dates when they are only run noise, and separators like `_`, `-`, and `%20`; title-case ordinary words while preserving known acronyms.
     - Use a fallback like `Personal CRM Intake` only when there is no usable filename or URL slug.
   - CSV: read the attached/opened CSV text, verify UTF-8-compatible content, size under 25 MB when knowable, a non-empty header, and at least one non-empty data row.
   - Lu.ma: accept only `lu.ma`, `www.lu.ma`, `luma.com`, `www.luma.com`, or any host ending in `.lu.ma`.
   - Brella: accept only `brella.io`, `www.brella.io`, or any host ending in `.brella.io`.
   - Partiful: accept only `partiful.com`, `www.partiful.com`, or `go.partiful.com`.
   - Let the MCP be the final validator and report MCP validation errors plainly.

3. Submit through MCP.
   - CSV: call `submit_csv_intake(event_name, csv_content, file_name?, source_name?, source_profile?, run_label?, run_slug?)`.
   - Lu.ma: call `submit_luma_intake(event_name, luma_url, max_items?, max_total_charge_usd?, timeout_seconds?, memory_mb?, run_label?, run_slug?)`.
   - Brella: call `submit_brella_intake(event_name, brella_url, max_items?, timeout_seconds?, run_label?, run_slug?)`.
   - Partiful: call `submit_partiful_intake(event_name, partiful_url, max_items?, timeout_seconds?, run_label?, run_slug?)`.
   - Preserve default caps unless the user gives explicit alternatives.

4. Report a friendly started card.
   - Use `run_label` as the operator-facing `Run ID`.
   - Map source labels to `CSV`, `Lu.ma`, `Brella`, or `Partiful`.
   - Do not show `Endpoint`, `Log`, `Intake`, `Exports`, `Slug`, `pid`, or `alive=true` in normal started/running/completed output.
   - Treat `run_slug`, `pid`, and Mac-mini filesystem paths as maintainer debug metadata only.

5. Track status tersely.
   - Poll with `get_intake_status(run_label=<run_label>)` or `get_intake_status(run_slug=<run_slug>)`.
   - Emit chat updates only when status or process-alive state changes, or at most about once per minute.
   - Use compact lines like: `Still running: <event_name> | <source_label> | Run ID: <run_label>`.
   - Do not paste raw tool payloads.
   - Show Mac-mini paths only when the run failed or the user explicitly asks for debug details.

## Operator Output

Started/running response:

```text
Started Personal CRM pipeline

Event: <event_name>
Source: <CSV|Lu.ma|Brella|Partiful>
Run ID: <run_label>
Status: Running

Next: I'll keep this concise. Ask "check status for <event_name>" later to refresh the run.
```

Compact status update:

```text
Still running: <event_name> | <CSV|Lu.ma|Brella|Partiful> | Run ID: <run_label>
```

Completed response:

```text
Personal CRM pipeline completed

Event: <event_name>
Source: <CSV|Lu.ma|Brella|Partiful>
Run ID: <run_label>
Status: Completed

Result: Submitted to Personal CRM. Include counts only if the MCP status returns them.
```

Failed response:

```text
Personal CRM pipeline failed

Event: <event_name>
Source: <CSV|Lu.ma|Brella|Partiful>
Run ID: <run_label>
Status: Failed

Reason: <short MCP/status error if available>
Maintainer debug: <log_path>
Next: Ask a maintainer to inspect the log path.
```

For explicit debug requests, include `run_slug` as `Debug ID` and include the relevant Mac-mini paths. Do not show debug fields in normal operator output.

## Relationship To Other Skills

- Use this skill for remote operator submissions through MCP only.
- Use `$personal-crm-conference-e2e-run` for maintainer/debug runs that execute local commands.
- Use `$build-ai-b2b-agentic-saab-make-no-mistakes` for full repo readiness checks.
