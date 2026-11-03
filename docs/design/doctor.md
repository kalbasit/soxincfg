# `doctor`: a health check for a machine, contributed by modules

Status: **proposal, for the owner's review. Nothing is implemented.**
Everything below is generic: hostnames, addresses, keys and private paths are
inputs a consuming repository supplies, never values in this one.

## Problem

A `switch` can succeed and leave a machine unhealthy: a launchd agent was
booted out and never came back, a socket points at nothing, a deploy ran from
a stale checkout, a deploy target silently hangs on a hardware key. Today the
owner finds out by tripping over it. `doctor` states what "healthy" means, next
to the module that makes the promise, and says how to fix each failure.

## Design in one paragraph

A module declares checks under `soxin.doctor.checks.<name>`. Evaluating a
configuration produces a **manifest** (JSON plus the check scripts, all in the
store) installed into the system profile (NixOS, nix-darwin) or the home
profile (home-manager). A small **runner**, `doctor`, discovers the manifests
on the machine, runs the selected checks (each with a hard timeout), and prints
human output or JSON. Each failing check prints its runbook's fix steps. The
runner is read-only and runs unattended.

## 1. The check contract

### Declaration

```nix
soxin.doctor.checks.ssh-agent-keys = {
  description = "The ssh agent named by SSH_AUTH_SOCK lists at least one key";
  group = "ssh";
  scope = "user";               # "user" | "system"
  roles = [ ];                  # host-role tags; empty = every host
  severity = "error";           # "error" | "warning": what a failure counts as
  command = pkgs.writeShellApplication { ... };   # any executable, see below
  timeout = 10;                 # seconds, default 10
  requires = [ "ssh-agent-socket" ];   # skipped when one of these did not pass
  network = [ ];                # hosts the check may contact; [] = none
  needsRoot = false;            # true = skipped, never escalated, when not root
  runbook = ./runbooks/ssh-agent-keys.md;
};
```

| Field | Meaning |
| --- | --- |
| name (attr key) | `[a-z0-9-]+`, unique across every layer. The same name from two layers merges as module options do, and a conflict is an evaluation error. |
| `description` | One line, shown in `--list` and in the human output. |
| `group` | A free tag for selection and display (`ssh`, `services`, `deploy`, ...). |
| `scope` | `user`: needs the invoking user's session (their environment, `$HOME`, user bus). `system`: about the machine; runs as the invoking user too and never needs root unless `needsRoot` says so. |
| `roles` | Host-role tags the owner assigns with `soxin.doctor.roles` (generic tags such as `workstation`, `server`, `builder`, `deploy-controller`). A check whose roles do not intersect the host's is not in that host's manifest at all. It is not shown as skipped, because it does not apply. |
| `severity` | `error` or `warning`. It caps what a failing check reports: a `warning` check that fails reports `warn`. |
| `command` | An executable in the store. Helpers build it from a script plus `runtimeInputs`, so a check never depends on what the user happens to have in `PATH`. A path outside the store (an existing project script) is allowed through `commandPath`, marked `impure` in the manifest and in the output. |
| `timeout` | Seconds. Enforced by the runner, see below. |
| `requires` | Names of checks. If one did not `pass`, this check is `skip` with the reason `requires <name>`. This keeps one root cause from printing five failures. |
| `network` | Declared destinations. The runner skips the check unless `--allow-network` is given (see section 4). |
| `needsRoot` | Skipped with a reason when the runner is not root. The runner never calls `sudo`. |
| `runbook` | See "The runbook" below. A check without one is an evaluation error. |

The owner of a consuming repository can tune a check from outside without
touching its module: `.enable = false`, `.timeout`, `.severity`, or `.roles`.

### Running a check: the protocol

The runner starts `command` with stdin closed (`/dev/null`), a private
temporary directory as `$TMPDIR`, a scrubbed environment (an allowlist: `HOME`,
`USER`, `PATH`, `XDG_*`, `SSH_AUTH_SOCK`, `DBUS_SESSION_BUS_ADDRESS`, `LANG`;
plus `GIT_TERMINAL_PROMPT=0`, no `SSH_ASKPASS`), in its own process group. The
protocol is the plain Unix one, so any existing script can be wrapped:

| Exit | Result |
| --- | --- |
| `0` | `pass` |
| `1` | `fail` (reported as `warn` when `severity = "warning"`) |
| `10` | `warn` (the check decides this itself) |
| `77` | `skip` (convention of the automake test driver); the reason is the first stdout line |
| anything else, or a signal | `fail`, cause `crashed`, with the exit status and the tail of stderr |

Output: the **first stdout line** is the message (what is true, in one
sentence, for example `agent lists 0 identities`). Further stdout lines are
details, shown on failure or with `-v`. stderr is captured, truncated to 4 KiB
and shown only on failure. A check must not print a secret or a full command
line carrying one; the runner also truncates and applies a best-effort filter
for private-key blocks and common token shapes, but the filter is a safety net,
not the contract.

### Timeouts

A check never hangs. The runner waits `timeout` seconds, then sends `SIGTERM`
to the check's whole process group, and `SIGKILL` two seconds later. The result
is `fail` (not `skip`), cause `timeout`, message
`timed out after 10s`, with whatever stdout and stderr the check had produced.
A check can therefore explain a hang by printing progress lines (`stage: ssh
auth`) before it blocks; the runner shows the last one. There is also a global
budget (`--budget`, default 120 s) after which unstarted checks are `skip`
with the reason `budget exhausted`. Checks run in parallel (default 8) so a few
slow ones do not decide the total.

### Results

Four statuses, plus a **cause** that says why:

| Status | Used for |
| --- | --- |
| `pass` | the condition holds |
| `warn` | degraded, or the check could not conclude (cause `inconclusive`, see 5f) |
| `fail` | the condition does not hold, the check timed out, or it crashed |
| `skip` | not applicable or not runnable here, always with a reason (`requires`, `needs root`, `no user bus`, `offline`, `budget exhausted`) |

Cause values: `condition`, `timeout`, `crashed`, `inconclusive`,
`precondition`, `skipped-network`, `skipped-requires`, `skipped-root`,
`skipped-budget`.

### The runbook

- **Where it lives.** A Markdown file in the repository that owns the check,
  next to the module (`modules/<area>/<name>/runbooks/<check>.md`). Its path
  is the `runbook` attribute. The file is copied into the manifest, so the
  runbook the machine shows is the one that was built with it. A private repo
  can add a runbook for a private check in its own tree, and can append site
  notes to a public check's runbook with `runbook.extra = ./notes.md`, which is
  shown after the public text.
- **Shape.** Required level-2 headings, enforced by a build-time check: `Symptom`,
  `Cause`, `Fix` (a numbered list, one command or action per step) and `Verify`
  (the command that proves it fixed: normally `doctor <check>`). The
  `Fix` steps are the only thing a failing check prints inline.
- **How it is shown.** On `warn`/`fail` the human output prints the `Fix`
  steps (at most 8 lines, then `... see doctor runbook <check>`), and the
  JSON carries `runbook.fix` (the steps), `runbook.path` (in the store) and
  `runbook.url` when `runbookUrl` is set. `doctor runbook <check>` prints the
  whole file as plain text; there is no Markdown renderer dependency. A
  repository that publishes its docs sets `soxin.doctor.runbookBaseUrl` and
  every check gets a link for free.
- **What it must not hold.** No secrets, no host-specific values. A public
  runbook says `the deploy target` and tells the reader to look at the check's
  detail lines, where the runner prints the real value at run time.

## 2. Registration and layering

### Where the mechanism belongs

The option has to be declared by the lowest layer that wants to contribute. If
it lived in soxincfg, a Soxin module (for example the yubikey module in the
module library) could not add a check without referencing soxincfg, and
dependencies point one way: private -> public, soxincfg -> soxin.

Recommendation:

| Piece | Lives in | Why |
| --- | --- | --- |
| Option schema, manifest builder, the runner, the helper library (`wrap`, the service-check generator, the probe shell library) | **soxin** (`modules/library/doctor/`, per kind like the other library modules, plus a `packages` entry) | Every layer can contribute; one runner for the whole stack; a fleet that uses soxin without soxincfg gets it. |
| Checks for behaviour soxin's own modules promise | soxin, next to each module | "next to the modules they belong to" |
| Checks for soxincfg's modules, and the generic first checks of section 5 | **soxincfg**, next to each module, as `soxin.doctor.checks.<name>` | soxincfg modules know their own services and sockets. |
| Checks for private modules, targets, paths, existing scripts | the private repo | The only place private values may be. |

The namespace is therefore `soxin.doctor.*`, not `soxincfg.doctor.*`: a
soxincfg-only namespace would block the layering above. soxincfg keeps its own
`soxincfg.*` options for its modules and only contributes `soxin.doctor.checks`
entries. Alternative if the owner prefers to avoid a soxin change first: build
the same thing in soxincfg as `soxincfg.doctor.*` and move it to soxin later;
the cost is a rename of every check declaration. I do not recommend it.

### How a downstream repo extends it without leaking

A check is generic code driven by options. For example:

```nix
# public (soxincfg or soxin): the mechanism and the generic check
soxin.doctor.deployTargets = mkOption { type = attrsOf (submodule ...); default = { }; };
# the check "deploy-target-ssh" exists only when this set is non-empty

# private repo: only values
soxin.doctor.deployTargets.build-box = { host = "..."; user = "..."; };
```

Rules that keep the public side clean:

1. A public check takes everything host-specific from an option with no
   default; with no value the check is not generated.
2. A check's name describes what it tests, never who it tests for.
3. Runbooks, descriptions and messages in public repos are generic. Values
   appear only in run-time output, which is never committed.
4. A private repo adds its own checks under the same option, with their runbooks
   in its own tree. They appear in the same `doctor` output and the same JSON.
5. A mechanical guard: soxin already has a guard (`guard/soxin-guard.py`) that
   enforces its public rule; a flake check in each public repo scans
   `docs/`, runbooks and check descriptions for a deny-list that CI supplies
   from a secret (the list itself cannot be committed). Open question 6.

### Where the manifest goes

Each kind installs a package with `share/soxin-doctor/checks.d/<name>.json`,
`.../bin/` (the check scripts) and `.../runbooks/`: `environment.systemPackages`
on NixOS and nix-darwin, `home.packages` for home-manager. The runner reads
every `share/soxin-doctor` found in the system profile, the user's profile and
each `XDG_DATA_DIRS` entry. A standalone home-manager host therefore needs no
system part, and a NixOS host with home-manager users gets both: system checks
from the system profile and user checks from the user's profile, in one run.
Because the manifest lives on the machine, `doctor` needs no flake evaluation
and no network at run time.

## 3. Platforms

The generated **service check** is the core of this section. The service
modules already say what is enabled; `doctor` derives the expectation from
the same configuration instead of anyone listing services twice.

### NixOS: systemd

- System units: from `config.systemd.services`, `sockets` and `timers` that
  the configuration enables (`wantedBy` reaches `multi-user.target`,
  `sockets.target` or `timers.target`).
- User units: from the home-manager `systemd.user.*` (and `systemd.user.*` on
  NixOS), `wantedBy` reaching `default.target`.
- Expectation per unit, computed at evaluation time: a long-running service
  must be `active (running)`; a `Type=oneshot` without `RemainAfterExit` must
  have `Result=success` for its last run; a unit with a timer expects the
  timer `active` and the last run `success`; a socket unit expects `active
  (listening)`. Readers use `systemctl show -p ActiveState,SubState,Result,NRestarts`
  (a stable key=value interface), not `systemctl status`.
- Extra signals: `NRestarts > 0` with a recent start is `warn` (a crash loop
  that is currently "running").
- `systemctl --user` needs a user bus. Without `XDG_RUNTIME_DIR` / bus
  (for example over a plain ssh session without a user manager), the user-unit
  check is `skip`, reason `no user bus`, never a failure.
- A module opts a unit out or overrides the expectation with
  `soxin.doctor.services.<unit>.expect = "ignore" | "running" | "oneshot-ok" | ...`.

### nix-darwin and home-manager: launchd

- Daemons (`launchd.daemons`, domain `system`) and agents (`launchd.user.agents`
  and home-manager `launchd.agents`, domain `gui/<uid>`, falling back to
  `user/<uid>` when there is no GUI session, in which case GUI-only agents
  are `skip`, reason `no GUI session`). The label is `serviceConfig.Label`, or
  the module's default label.
- Expectation from the plist: `KeepAlive` set -> `running` with a pid;
  `StartInterval` or `StartCalendarInterval` -> `loaded` and last exit status
  `0`; `RunAtLoad` only -> `loaded`, and either running or last exit status
  `0`.
- Reading state: `launchctl print <domain>/<label>` and take only `state`,
  `pid` and `last exit status`. Its format is not a documented interface, so
  the parser (a) matches those three keys only, (b) treats "could not find
  service" as the distinct, useful result **not loaded**, which is exactly the
  failure after a switch boots out an agent that nothing reloads, and
  (c) treats an empty or unparseable output as `inconclusive` (see 5f), then
  falls back to `launchctl list <label>`.

### Is the socket or port alive?

Being loaded is not being useful. A service can declare a **liveness probe**
next to its module:

```nix
soxin.doctor.services.my-service.probe = {
  unixSocket = "$XDG_RUNTIME_DIR/my.sock";   # path is a socket and connect() succeeds
  # tcp = { host = "127.0.0.1"; port = 8080; };  # connect() succeeds within 2s
  # command = [ "ssh-add" "-l" ];                # protocol-level probe, own timeout
};
```

- Probes use `connect()` with a timeout, not `netstat`, `ss` or `lsof`: that
  tests what a client experiences and is immune to the tool-output problem of
  5f.
- **Side effect rule.** Connecting to a socket-activated service starts it.
  For a socket owned by a `.socket` unit (systemd) or `Sockets` in a plist
  (launchd), the default probe is passive: the socket unit is `active` and the
  path exists with the right type. Only a probe with `activates = true` connects,
  and such a probe is listed as non-read-only in the manifest and is skipped
  under `--read-only-strict`.
- A stale socket file (exists, `connect()` is refused) is reported as such:
  `socket exists but nothing is listening`.

## 4. Output and use

```
doctor [--list] [--json] [-v] [--check <glob>...] [--group <g>...]
       [--scope user|system] [--severity error|warning]
       [--allow-network] [--timeout-scale <n>] [--budget <s>]
doctor runbook <check>
```

- **Human output (default).** Grouped, one line per check, color and glyphs
  only on a terminal (`NO_COLOR` and a non-tty fall back to `ok`/`WARN`/`FAIL`/
  `skip`). Failing checks print their detail lines and the runbook `Fix`
  steps indented under them. The last line is a count.

  ```
  ssh
    ok    ssh-agent-socket    SSH_AUTH_SOCK is a live socket
    FAIL  ssh-agent-keys      agent lists 0 identities
            1. Unlock or insert the key the agent should offer.
            2. Run `ssh-add -l`; it should list a key.
            ... see: doctor runbook ssh-agent-keys
  services
    FAIL  units               1 of 24 not running: <unit> (not loaded)
  ```

- **JSON (`--json`).** One document on stdout, nothing else on stdout:

  ```json
  {
    "schema": 1,
    "host": {"kind": "darwin", "roles": ["workstation"], "name": "<runtime hostname>"},
    "runner": {"version": "…", "started": "…", "duration_ms": 1830},
    "summary": {"pass": 20, "warn": 1, "fail": 2, "skip": 3},
    "results": [{
      "check": "ssh-agent-keys", "group": "ssh", "scope": "user",
      "severity": "error", "status": "fail", "cause": "condition",
      "message": "agent lists 0 identities", "details": ["…"],
      "duration_ms": 112, "exit": 1, "impure": false,
      "reason": null,
      "runbook": {"fix": ["…"], "path": "…", "url": null}
    }]
  }
  ```

  The schema is versioned (`schema`), additive within a version, and ships as a
  JSON Schema file that a test validates against. Timestamps are RFC 3339;
  `duration_ms` is wall time. Logs and progress go to stderr, so a fleet tool
  or an agent can pipe stdout straight into `jq`.
- **Exit codes of `doctor`.** `0` all passed (skips allowed); `1` warnings,
  no failures; `2` at least one failure; `3` the runner itself failed (bad
  arguments, unreadable manifest, selection matched nothing). `--strict` makes
  warnings exit `2`. These match the Nagios plugin convention for 0, 1 and 2,
  so existing monitoring glue works.
- **Selecting.** `doctor ssh-agent-keys` or `--check 'ssh-*'` runs one or a few;
  `--group services` runs a group; `--scope user` runs only user checks (what a
  login hook wants). A selected check whose `requires` is not selected still
  has its requirements evaluated, but not shown.
- **Unattended safety.**
  1. *Read-only.* Checks run with `$TMPDIR` private and removed afterward, and
     the contract forbids writing elsewhere, starting or restarting units,
     `switch`, `nix-store --realise`, or any state change. It is enforced by
     review and by a test that runs every check against a fake root and fails
     on writes (Linux, using a read-only bind mount; on darwin the test
     compares a directory snapshot before and after).
  2. *No secrets printed.* See the protocol: checks print identifiers and
     counts (`2 identities`), not key comments, tokens or full command lines.
  3. *No network beyond what a check declares.* `network` is policy, not a
     sandbox: the runner skips a check that declares destinations unless
     `--allow-network`, and prints the declared destinations in `--list`. On
     Linux the test suite additionally runs every check that declares none
     inside a network namespace and fails if it connects out. That is not
     possible on darwin, so there it is review only (stated honestly in
     open question 4).
  4. *Bounded.* Per-check timeout, global budget, output truncation.
  5. *No prompts.* stdin is closed and prompting variables are unset.

## 5. First checks

All are generic; values come from options. Each has a runbook.

### a. `ssh-agent-socket` and `ssh-agent-keys` (scope `user`)

Two checks, the second `requires` the first, so a dead agent prints one
failure.

- `ssh-agent-socket`: `SSH_AUTH_SOCK` is set, names a path that is a socket
  (`test -S`), and `connect()` succeeds. Unset -> `fail` (message says it is
  unset, and that the session environment, not the agent, may be the
  problem; on darwin the runner also reads `launchctl getenv SSH_AUTH_SOCK`
  and reports when launchd and the shell disagree, which is what a restarted
  agent that nobody re-exported looks like). Stale file -> `fail`, `socket
  exists but nothing is listening`.
- `ssh-agent-keys`: `ssh-add -l` under a 5 s timeout with stdin closed. Exit
  `0` -> `pass`, message `N identities`. Exit `1` -> `fail`, `agent reachable
  but lists no identities` (the likely causes are in the runbook: an
  upstream agent in a multiplexer is down, a hardware key is detached). Exit `2`
  -> `fail`, `cannot talk to the agent`. Only the count is printed, never the
  comments or fingerprints.
- The incident that motivates this (a switch stopped an agent multiplexer and
  launchd never restarted it) is caught twice, from both sides, by (b) and by
  these two.

### b. `units`: every enabled launchd agent and systemd unit is loaded and running

The generated service check of section 3, in two instances: `units-system`
(scope `system`) and `units-user` (scope `user`). One aggregated result per
instance, naming each failing unit in the details (`<unit>: not loaded`,
`<unit>: failed (exit 1)`, `<unit>: restarted 7 times`), because the runbook
for "a unit is not running" is the same for all of them: how to read its log,
how to reload it (`launchctl bootstrap`/`kickstart`, `systemctl reset-failed`
and `restart`), and what *not* to do (do not edit the generated plist or unit).
A module that needs a unit-specific runbook adds an explicit check next to the
module; it replaces that unit in the aggregate. This check, with a liveness
probe where a module declares one, is the main way new modules get coverage.

### c. `config-checkout-fresh` (scope `user`)

Generated only when `soxin.doctor.configCheckout.path` is set (a path on the
machine, supplied by the host's configuration).

- Offline (default): compares `HEAD` with the already-fetched upstream
  branch (`git rev-list --left-right --count HEAD...@{u}`). Behind -> `fail`
  with the count; diverged -> `fail`; dirty tree -> `warn`; ahead -> `pass`
  with a note. If the last fetch is older than `staleAfter` (default 7 days,
  from `FETCH_HEAD`'s mtime) the offline answer cannot be trusted: `warn`,
  `upstream last fetched N days ago`, which is the honest outcome rather than
  a green check on old data.
- With `--allow-network`: `git ls-remote` (read-only; it does not write
  refs) under `GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5'`,
  compared with `HEAD`. If the remote tip is not in the local object store the
  checkout is behind.
- Related, optional: the revision a system was built from
  (`system.configurationRevision`, readable from the running system) versus
  `HEAD`; tells "deployed from a stale checkout" after the fact.

### d. `deploy-target-ssh`: deploy targets reachable as the deploy user

Input: `soxin.doctor.deployTargets.<name> = { host; user; port ? 22; }`, filled
by the private repo. Open question 3 asks whether to derive these from the
deploy tool's own machine inventory instead. `network` is declared (the
targets), so it needs `--allow-network`.

A silent hang is the failure to eliminate, so the probe is **staged**, each stage
with its own short timeout, and the failure names the stage:

1. TCP connect to `host:port` (2 s). `refused`, `no route`, `timed out`.
2. SSH banner (3 s). Reached something that is not (or not yet) an ssh server.
3. Authentication: `ssh -o BatchMode=yes -o ConnectTimeout=5
   -o PreferredAuthentications=publickey -o StrictHostKeyChecking=yes
   -o ControlMaster=no -l <user> -p <port> <host> true`, with a hard 10 s
   timeout and `-v`.

`BatchMode=yes` stops password prompts, but it does **not** stop ssh waiting for
an agent that is itself waiting, for example for a touch on a hardware key. On
timeout in stage 3 the check reads the `-v` log it captured: if the last line
is the one printed when ssh hands a signing request to the agent
(`sign_and_send_pubkey`), the reason is `authentication timed out: waiting for
the agent to sign (a hardware key may need a touch, or the agent is stuck)`;
otherwise it is a generic `timed out in stage auth`. The `-v` text is only
used to choose a better *reason*; the timeout itself does not depend on it, so
a change of ssh's wording degrades the message, never the safety. Other
reasons come from ssh's exit code `255` plus a short list of stable messages
(`Permission denied (publickey)`, `Host key verification failed`,
`Connection refused`), anything else shown verbatim as the tail of stderr.
One result per target, so a fleet tool sees which one failed; `requires`
`ssh-agent-keys`.

### e. Wrapping an existing script as a provider

`soxin.doctor.lib.wrap` adapts a script that predates the contract:

```nix
soxin.doctor.checks.project-selftest = soxin.doctor.lib.wrap {
  description = "The project's own self-test passes";
  group = "project";
  command = "${self}/scripts/selftest.sh";   # or commandPath for a checkout path
  pass = [ 0 ];  warn = [ 3 ];  skip = [ 77 ];   # exit codes of the old script
  message = "last-line";                          # or "first-line", "json:.summary"
  timeout = 60;
  runbook = ./runbooks/project-selftest.md;
};
```

`wrap` gives the script the protocol of section 1 (exit mapping, message
extraction, timeout) without editing the script. This is how a private repo
contributes its existing self-test script: the script and the `wrap` call are
private, the contract and the runner are public. Anything the script prints is
still subject to the no-secrets rule, so `wrap` only forwards the extracted
message by default, with raw output behind `details = "forward"`.

### f. "The tool printed nothing" versus "the condition is false"

The false failures came from treating **empty output** as **no match**. The
rule, built into the helper library and the review checklist:

1. **Prefer a direct probe over scraping.** `connect()` for a port, `stat` for
   a socket, `launchctl print` for a service, an exit code for a yes/no
   question. Parsing a tool's text for absence is the last resort.
2. **If you must scrape, classify the tool run first.** The shell library gives
   `doctor_capture <name> -- cmd...`, which records exit status, stdout bytes
   and stderr, and returns one of: `ok`, `tool-missing`, `tool-error` (non-zero
   exit with the reason), `tool-empty` (exit 0 and zero bytes of stdout).
3. **`tool-empty` is never "condition false".** A scraping check must then
   decide whether empty is legitimate. It declares what a *good run* looks
   like (`expect-header '^Proto'`, `expect-min-rows 1`, or a **canary**: query
   something that must be present, such as the check's own listening probe
   socket or loopback). If the canary is absent, the tool is unusable, the
   result is `warn`, cause `inconclusive`, message `<tool> printed nothing
   (exit 0): its output is not usable here; the condition was not evaluated`.
   If the canary is present and the target is absent, the condition is false
   and the result is `fail`.
4. **Why `warn` and not `fail` or `skip`.** The machine is not shown to be
   unhealthy (so not `fail`), but the health check itself is blind (so not a
   quiet `skip`, which means "not applicable"). It surfaces and does not make
   the exit status `2`.
5. **A regression test per scraping check** replaces the tool with a shim that
   prints nothing and exits `0`, and asserts `warn/inconclusive`, plus a shim
   that prints a good run without the target and asserts `fail/condition`. The
   case that started this (`netstat -anv -p tcp` printing nothing on a recent
   macOS) is the first fixture.

## 6. Prior art and what to reuse

| Project | What it does | Reuse |
| --- | --- | --- |
| `brew doctor` | A list of checks, each returning prose with the fix inline; exits non-zero on any finding | The tone, and fix text next to the failure. Not the single binary list: contributions cannot come from other repos. |
| `flutter doctor` | Validators grouped by category, ok / warning / error glyphs, per-category fix hints, `-v` | The grouped output, the `-v` detail level, "a missing optional tool is a warning". |
| NixOS tests (`nixosTest`) | Boot a VM and assert (`wait_for_unit`, `wait_for_open_port`) before shipping | Complementary: they test a configuration *before* deploy, in a VM, and cannot see launchd or a live user session. Reuse the vocabulary of the probes, and run `doctor` inside a NixOS VM test for the NixOS part of the test suite. |
| home-manager activation checks (`home.activation` with the `check*` entries) | Run during `switch`, may abort it | Do not copy: `doctor` runs after the fact, unattended, and must not block a switch. An optional later step can run `doctor --group services` at the end of activation as a non-fatal warning. |
| `nixos-healthchecks` (mrVanDalo) | NixOS module options for health checks written next to service definitions, run from the flake, Prometheus output | The closest prior art and the same core idea (checks declared by modules). It is NixOS-only, has no scope/severity/runbook/timeout contract, and no launchd or home-manager side. Reuse its idea and compare option names; I would not adopt it as the base because of the missing darwin side and the contract. Worth checking before building whether it could host the NixOS half (open question 7). |
| `nix doctor` (Nix), `nix-health` / `omnix-health` | Health of the Nix installation itself (store, flakes enabled, trusted users) | Not about services or user sessions. `doctor` could contribute a `nix-health` wrapper check through `wrap` if the owner wants it. |
| `NixOS/nixpkgs` `system.checks`, module `assertions`/`warnings` | Evaluation- and build-time validation | Reuse `assertions` for the contract (a check without a runbook fails evaluation). |
| Nagios plugin API, automake test driver, TAP | Exit-code contract with 0/1/2, 77 = skip; single-line message | The exit-code contract (sections 1 and 4), so existing scripts wrap without changes. |
| goss / InSpec | Declarative host validation | Not adopted (a second language), but the probe vocabulary (`service`, `port`, `file`, `command`) is the same. |

## 7. Rollout

Each PR is reviewable alone, has tests that fail without it, and leaves
`doctor` working for whatever exists so far.

| # | Repo | Content | Tests | Effort |
| --- | --- | --- | --- | --- |
| 1 | soxin | `soxin.doctor` option schema (three kinds), manifest builder and installed package, the runner (Python, standard library only, as `guard/` and `parity/` already are), `--list`, human and JSON output, exit codes, `requires`, timeouts, budget, `wrap`, the runbook format check, the JSON Schema | Runner unit tests with fake checks: every exit code, a hang (timeout, killed process group, a child that ignores `SIGTERM`), `requires` skip, output truncation, JSON validated against the schema, evaluation tests (a check with no runbook fails, a duplicate name merges or errors), `doctor` run in a NixOS VM test | 3 to 4 days |
| 2 | soxin | The generated service check (systemd and launchd readers, expectation rules, probes, passive socket rule) and the probe/`doctor_capture` shell library | Fixtures: fake `systemctl` and `launchctl` shims for each state (running, failed, not loaded, restart loop, oneshot, timer, no bus, no GUI session, **empty output**), the VM test with a service killed after boot, a darwin manual check list for the owner (no darwin CI) | 3 days |
| 3 | soxincfg | Wire `soxin.doctor` into the module library and profiles; first checks a and b with runbooks; the doc for how modules add a check; the flake check that runs the runner's fixture tests | Eval of each host; fixture tests for a and b; `nix flake check` | 1.5 days |
| 4 | soxincfg | Checks c and d (options, staged ssh probe, offline and networked modes), runbooks | Fixture tests with a local `sshd` on a loopback port in a VM test (refused, wrong key, host key mismatch, an agent that never answers = the hang), a git fixture repo for c (behind, ahead, diverged, dirty, never fetched) | 2 days |
| 5 | private repo | Values for `deployTargets` and `configCheckout`, the `wrap` of the existing self-test, private runbooks, any private checks | The private repo's own checks; this item only needs the three lines of values and the wrap | 0.5 to 1 day |
| 6 | soxincfg or soxin (optional) | A non-fatal `doctor --group services` after activation; a periodic user unit/agent running `doctor --json` for a fleet tool to read | Activation test; timer test | 1 day |

Total about 11 to 13 days of work for 1 to 5. Merge order is soxin first (1,
2), then update soxincfg's `soxin` input, then 3, 4; the private repo (5) after.

## Open questions for the owner

1. **Where the mechanism lives.** I recommend soxin (`soxin.doctor.*`), with
   soxincfg contributing checks. The alternative, `soxincfg.doctor.*` first, is
   quicker to start and costs a rename later. Which?
2. **Severity vocabulary.** Two levels (`error`, `warning`) plus the check's own
   exit `10` for warn. Is that enough, or do you want a third that never
   affects the exit code (`info`)?
3. **Deploy targets.** Fill `soxin.doctor.deployTargets` by hand in the private
   repo, or derive them from the deploy tool's machine inventory (Clan's
   target host settings), which today none of the machines set?
4. **Network policy on darwin.** On Linux the tests can enforce "declares no
   network, uses none" with a namespace; on darwin the declaration is policy
   and review only. Acceptable?
5. **`inconclusive` as `warn`.** The recommendation in 5f: an unusable tool is
   a `warn`, not a `fail` or a `skip`. Agree?
6. **Guarding the public side.** A deny-list scan of `docs/` and runbooks needs a
   list that cannot be committed here. Do you want it as a CI secret, or is
   review enough, as for the rest of the repository?
7. **Build or adopt.** `nixos-healthchecks` has the same core idea for NixOS. Do
   you want me to evaluate hosting the NixOS half on it before PR 1, or build
   the whole thing on this contract so darwin and home-manager are not a second
   system?
8. **Runner language.** Python standard library, as the existing tools in soxin,
   or a compiled binary (Go or Rust) so it starts fast and has no interpreter
   dependency?
9. **The run at the end of a switch.** Do you want PR 6 (non-fatal `doctor` after
   activation), or should `doctor` stay a command you run?

## What this design does not decide or cover

- No implementation, no soxin change, no test has been run: this is a proposal.
- Windows and WSL-specific behaviour are not covered (WSL is NixOS and gets
  the systemd side).
- The macOS `launchctl print` format is undocumented; the reader is designed
  to degrade to `inconclusive`, but it has not been tried on a recent macOS
  from this session (no darwin host here), so the parser needs a first
  run on the owner's machine.
- Remote execution (running `doctor` on a fleet from one machine) is out of
  scope: the JSON and exit codes are the interface a fleet tool builds on.
