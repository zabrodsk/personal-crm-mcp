---
name: start-crm-pipeline
description: Project-local Personal CRM operator workflow for starting or checking CSV, Lu.ma, Brella, and Partiful pipeline runs through the connected personal-crm-intake MCP only. Use inside the personal-crm repository when the user says start CRM pipeline, use the MCP, submit an attached CSV or event link, check Personal CRM status, or track a Personal CRM MCP run from Codex, Claude, Cursor, or another MCP-connected agent.
---

# Start CRM Pipeline

Use this skill for operator-facing Personal CRM intake through the official MCP. This is a routing and reporting skill, not a maintainer runbook.

Official MCP URL: `https://clawdbot--mac-mini.taild9e247.ts.net:8798/mcp`
Operator-facing endpoint name: `personal-crm-intake` on the Clawdbot Mac mini
Live monitor: `https://clawdbot--mac-mini.taild9e247.ts.net:8443/`

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
   - If `event_name` is missing, infer it conservatively:
     - CSV: derive it from the attached/opened filename.
     - Lu.ma, Brella, or Partiful: derive it from the event URL slug/path only when the slug contains readable event words.
     - Normalize the inferred name into a readable title by removing extensions, IDs, query strings, dates when they are only run noise, and separators like `_`, `-`, and `%20`; title-case ordinary words while preserving known acronyms.
     - Treat opaque URL IDs such as `p5336zo5`, `evt_123`, UUIDs, or short alphanumeric hashes as unusable names.
     - If a Lu.ma, Brella, or Partiful URL has no readable event name, stop and ask the operator for the event/conference name before submitting.
     - Use a fallback like `Personal CRM Intake` only for CSV submissions when there is no usable filename or explicit source name.
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

4. Wait for a people count, then report a friendly started card.
   - Map source labels to `CSV`, `Lu.ma`, `Brella`, or `Partiful`.
   - Use `Name`, not `Event`, in operator-facing output.
   - Include `People: <count>` in the initial card. Do not use placeholders like `Counting...`.
   - Prefer counts from imported/collected attendees. If the MCP has not imported yet, use `people_expected` from the submit/status response.
   - If `people_count_source=max_items_cap`, show `People: up to <count>` and base the estimate on that cap.
   - If the submit response does not include `people_count`, `people_expected`, or another usable attendee count, poll `get_intake_status` briefly until a count is available before sending the initial card.
   - Estimate total runtime as about `people_count * 1.1` minutes, rounded to a friendly whole-minute range or value.
   - Always include `Live monitor: https://clawdbot--mac-mini.taild9e247.ts.net:8443/`.
   - Do not show `Endpoint`, `Log`, `Intake`, `Exports`, `Slug`, `Run ID`, `pid`, `alive=true`, or `Process` in the initial started output.
   - Treat `run_slug`, `pid`, and Mac-mini filesystem paths as maintainer debug metadata only.

5. Track status tersely.
   - Poll with `get_intake_status(run_label=<run_label>)` or `get_intake_status(run_slug=<run_slug>)`.
   - Emit chat updates only when status or process-alive state changes, or at most about once per minute.
   - Show the current pipeline step only in check-status output, not in the initial started card.
   - Derive the current step from MCP status/stage/job/event fields when available; use `Starting` only if no stage is visible yet.
   - Use friendly step names such as `Collecting attendees`, `Importing`, `Enriching`, `Scoring`, `Deciding`, `Syncing`, `Completed`, or `Failed`.
   - For check-status runtime math, compute elapsed time from `started_at`/`created_at` in the MCP payload to the current time. Do not infer remaining work from a stage count or a nonexistent "people remaining" field.
   - Show total estimate as `people_count * 1.1` minutes. When useful, add `Elapsed: <elapsed>` and `Remaining estimate: about max(total_estimate - elapsed, 0)` while the run is active.
   - Use compact lines like: `<name> is still running | <source_label> | Step: <friendly_step> | People: <count> | Monitor: https://clawdbot--mac-mini.taild9e247.ts.net:8443/`.
   - Do not paste raw tool payloads.
   - Show Mac-mini paths only when the run failed or the user explicitly asks for debug details.

## Operator Output

Started/running response:

```text
Started Personal CRM pipeline

Name: <name>
Source: <CSV|Lu.ma|Brella|Partiful>
People: <count>
Estimated runtime: about <count * 1.1 rounded> minutes
Status: Running
Live monitor: https://clawdbot--mac-mini.taild9e247.ts.net:8443/

Next: Check status later to see the active pipeline step.
```

Check status response:

```text
<name> is still running

Source: <CSV|Lu.ma|Brella|Partiful>
People: <count>
Current step: <Collecting attendees|Importing|Enriching|Scoring|Deciding|Syncing|Starting>
Estimated runtime: about <count * 1.1 rounded> minutes total
Elapsed: <elapsed time since started_at/created_at, if available>
Remaining estimate: about <max(total estimate - elapsed, 0) rounded>
Status: Running
Live monitor: https://clawdbot--mac-mini.taild9e247.ts.net:8443/
```

Completed response:

```text
Personal CRM pipeline completed

Name: <name>
Source: <CSV|Lu.ma|Brella|Partiful>
People processed: <count>
Runtime: <actual runtime if available; otherwise omit>
Status: Completed
Live monitor: https://clawdbot--mac-mini.taild9e247.ts.net:8443/

Result: Submitted to Personal CRM.
```

Failed response:

```text
Personal CRM pipeline failed

Name: <name>
Source: <CSV|Lu.ma|Brella|Partiful>
People: <count if available>
Current step: <friendly_step if available>
Status: Failed
Live monitor: https://clawdbot--mac-mini.taild9e247.ts.net:8443/

Reason: <short MCP/status error if available>
Maintainer debug: <log_path>
Next: Ask a maintainer to inspect the log path.
```

For explicit debug requests, include `run_label` as `Run ID`, include `run_slug` as `Debug ID`, and include the relevant Mac-mini paths. Do not show debug fields in normal operator output.

## Relationship To Other Skills

- Use this skill for remote operator submissions through MCP only.
- Use `$personal-crm-conference-e2e-run` for maintainer/debug runs that execute local commands.
- Use `$build-ai-b2b-agentic-saab-make-no-mistakes` for full repo readiness checks.
