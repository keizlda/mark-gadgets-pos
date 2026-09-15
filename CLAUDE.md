# Mark Gadgets POS

Standalone POS/inventory system for Mark Gadgets' main store. Live,
actively-used production system with real store data — see "Data Safety"
below before touching anything in the database.

There is a sibling fork of this codebase, `mark-gadgets-cgn`, for the CGN
(Camiguin) branch, which treats CGN as its own independent store rather
than a bulk buyer of this store's inventory. Concepts here that don't exist
there: CGN Ledger, `cgn_resales` table, the Reports filter that excludes
sales to "CGN" as a customer.

## Tech Stack

- React 19 + Vite 8 + Tailwind v4
- Supabase (Postgres + Auth) called directly from the frontend — no custom
  backend server
- `react-router-dom` for routing, `recharts` for charts, `write-excel-file`
  for the Financial Excel export
- Lint: `oxlint` (not eslint) — config in `.oxlintrc.json`

## Folder Structure

```
src/
  pages/            One file per top-level route (Dashboard, Inventory,
                     Sales, Financial, Reports, SupplierPayables,
                     AfterSales, Login), plus subfolders for grouped pages:
    inventory/      AddDevice, AllDevices, LowStock, Reserved,
                     SupplierDefective
    sales/          NewSale, SalesHistory
    aftersales/     CustomerReturns
  components/       UI components, grouped to mirror pages/ (inventory,
                     sales, financial, payables, aftersales, dashboard,
                     auth, layout, common)
  services/         All Supabase calls live here, one file per domain
                     (salesService, inventoryService, returnsService,
                     expensesService, cgnResalesService, etc.) — pages/
                     components call these, never supabase-js directly
  hooks/            useIsAdmin, useServiceData, useToast
  lib/              supabaseClient.js — the single Supabase client instance
  utils/            datetime, search, deviceKind, exportFinancialReport
  data/             referenceData.js — static reference data
supabase/
  schema.sql        Full current-state schema — NOT auto-applied; see
                     "Supabase Schema Changes" below
  migrations/       Timestamped .sql files, one per hand-run change against
                     the live DB — a history log, not a runnable migration
                     chain (no Supabase CLI is used in this project)
  seed*.sql, historical_data_*.sql, verify_migrations.sql
    One-off data-loading/verification scripts from setup — not part of the
    normal workflow
```

## Running the App

```
npm install
npm run dev       # vite dev server
npm run build     # production build
npm run lint      # oxlint
npm run preview   # preview a production build locally
```

Needs a `.env` in the project root (gitignored, never committed) with:

```
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
```

Get real values from the Supabase dashboard (Project Settings → API) for
project ref `edgjetqgdkybfrtokvhk` ("Mark Gadgets" project). Only the
anon/public key goes here — never the service_role key, and never in any
committed file.

## Deploy

- GitHub repo: `keizlda/mark-gadgets-pos` (public)
- Vercel: connected via GitHub integration, auto-deploys on every push to
  `main`. No `vercel.json` env config and no local `.vercel/` link — deploy
  env vars (the same two `VITE_SUPABASE_*` names) are set directly in the
  Vercel project dashboard. Project name on Vercel is expected to match the
  repo name (`mark-gadgets-pos`) unless it's been renamed there — confirm
  on vercel.com if a push doesn't trigger the deploy you expect.
- No Vercel or Supabase CLI is installed/used locally as of this writing —
  everything goes through the GitHub push (Vercel) and the Supabase SQL
  Editor web dashboard (schema). `.claude/settings.json` pre-authorizes
  `vercel`/`supabase` CLI commands anyway in case that changes later.

## HOW YOU WORK ON THIS PROJECT

This is a live production system with real store data, and the established
workflow here is **pre-authorized** — don't stop to ask permission for the
steps below; just do them.

**Standard change loop:**
1. Make the code change.
2. `npm run build` (vite build) and `npm run lint` (oxlint) — fix whatever
   breaks rather than guessing.
3. `git add` the specific files that changed (never `git add -A`/`.` —
   check `git status` first so nothing unintended gets staged).
4. `git commit -m "..."` — new commits, not amends, unless told otherwise.
5. `git push origin main` — this triggers the Vercel auto-deploy. Push
   directly once a commit is verified; don't ask first.

**Supabase schema changes** (the database has real, live data — see Data
Safety below):
1. Write the SQL as a new timestamped file in `supabase/migrations/`
   (format: `YYYYMMDDHHMMSS_description.sql`, matching existing files).
2. Also update `supabase/schema.sql` directly so it keeps reflecting the
   full current-state schema (it's what a fresh project would be bootstrapped
   from — there's no migration-replay tooling, so it must stay accurate on
   its own).
3. Hand the migration SQL to the user to run in the Supabase SQL Editor (no
   CLI push exists for this project) — or run it yourself via the Supabase
   CLI/API if that becomes available on the new machine and is
   pre-authorized in `.claude/settings.json`.
4. Any atomic multi-step operation (e.g. "record a sale AND mark a device
   sold") must be a Postgres RPC (`security invoker`, `set search_path =
   public`), never a client-side multi-call sequence — a dropped connection
   between steps leaves data half-done.
5. RLS is on every table: one permissive `for all using (auth.role() =
   'authenticated')` policy; admin-only gating happens in the UI, not the
   RPC.

**Gotchas learned the hard way:**
- `create or replace function` with a changed parameter list creates a
  SECOND overload instead of replacing the first — symptom is "Could not
  choose the best candidate function." Always `drop function <exact old
  signature>` first.
- When writing a delete/undo RPC, grep the schema for every `references
  public.<table> (id)` pointing at the row being touched before writing the
  cleanup order — a missed one throws a raw FK-violation (23503).
- Every `promise.then(setState)` in a data-loading hook needs a `.catch()`
  — an uncaught rejection reads to the user as "my data got deleted," not
  "a query failed."

## Data Safety (this matters here — real users are actively using this)

- **Idempotent**: any SQL/script must be safe to re-run.
- **Targeted**: touch only the specific rows in question, never a blanket
  `update`/`delete` across a whole table.
- **Additive-only**: never `truncate`, never a destructive rewrite.
- **Verify current state before writing a fix** — query live data fresh
  rather than assuming from an earlier conversation or an old export.

Destructive git ops (force-push, `reset --hard`, deleting branches) still
need explicit confirmation — the pre-authorization above covers the
routine edit → build → lint → commit → push loop, not those.

## Status as of 2026-09-15

Working tree clean, fully pushed and in sync with `origin/main`. No open
`.env`/secret leaks tracked in git; `.env` and `.claude/settings.local.json`
are gitignored.

**Last worked on:** a run of return-flow and status-transition hardening —
guarding status-changing RPCs against stale-list races, letting a
repointed `sale_item` go through the return cycle again, closing a
`replace_return` signature-drift gap, and standardizing "Pro Max" catalog
naming to match the existing device-name convention.

**Known bugs:** none currently tracked (no TODO/FIXME markers in `src/`,
no open issues recorded).

**Next steps:** none specifically queued — pick up whatever the user asks
for next. If porting a feature from/to the `mark-gadgets-cgn` sibling
fork, check first whether it touches CGN-Ledger/`cgn_resales` concepts,
since those exist only here.
