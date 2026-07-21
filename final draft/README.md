# ZMM_VEND_UPLOAD (Program ZMM_VEND_MASTER) — Final Draft (FSD 30)

Enhancement of the existing vendor/supplier upload program per **FSD 30 —
`FSD_ZMM_VEND_UPLOAD`**. The baseline is in [../initial draft/ZMM_VEND_UPLOAD.txt](../initial%20draft/ZMM_VEND_UPLOAD.txt).

## Why this is a delta, not a full file
The baseline provided was an **SE38 print listing** (tokens run together, page
headers, line numbers) — not clean compilable ABAP. The changes are therefore
delivered as clean, compile-ready **units** in
[`ZMM_VEND_MASTER_FSD30_changes.abap`](ZMM_VEND_MASTER_FSD30_changes.abap),
each marked `NEW` / `MODIFIED` with exact placement and the change tag `"FSD30`.
Routines not listed are unchanged from the baseline.

## Change units

| Unit | Include | Type | What |
|---|---|---|---|
| 1 | `_TOP` | MOD | Add `rowno`, `stat_cc`, `stat_po` to `ty_log` / `ty_log_ex` |
| 2 | main | MOD | `START-OF-SELECTION`: call `validate_create`, activate **Change** mode (`rb_chg`), route error-only download |
| 3 | `_FORMS` | NEW | `validate_create` — mandatory + duplicate (GST/PAN) checks; drops bad rows |
| 4 | `_FORMS` | NEW | `validate_change` — BP mandatory & must exist |
| 5 | `_FORMS` | MOD | `extend_bp` — shared by Extend **and** Change: no hard stop, "already extended" (LFB1/LFM1) detection, blank-safe `datax`, per-role status |
| 6 | `_FORMS` | MOD | `create_bp_vendor` — set `msgty` S/W/E + `rowno`; stop silently dropping no-company-code rows |
| 7 | `_FORMS` | MOD | `display_log` — ALV columns: Row No, BP Number, Supplier Name, Status, CC/PO Ext., GST, PAN, Message |
| 8 | `_FORMS` | NEW | `download_error_log_cr` — error-only download (create) |
| 9 | `_FORMS` | NEW | `download_error_log_ex` — error-only download (extend/change) |
| 10 | `_SCR` | NOTE | No structural change; label `rb_chg` as "Change" |

## FSD requirement → unit mapping
- **R1 Processing log / error download** → Units 1, 2, 6, 7, 8, 9
- **R2 Auto-extend CC + Purch Org, separate status, already-extended** → Units 1, 5, 6
- **R3 Separate Change mode (blank-safe)** → Units 2, 4, 5
- **R4 Validation + duplicate checks, no batch stop** → Units 3, 4, 5

## Open points to confirm before transport (from FSD gaps)
- **O4** Duplicate-check precedence (GST vs PAN vs Tax No.) and whether a
  DB-level PAN match is an error or just a warning.
- Company-code / purch-org fields assumed present & valid in the file (FSD
  assumption). Validation warns rather than hard-fails where possible.
- Confirm message class if formal message IDs are preferred over literal text.
