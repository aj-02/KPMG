# Technical Specification (TS) — ZMM_VEND_UPLOAD Enhancement (FSD 30)

| | |
|---|---|
| **Client** | Astral Limited |
| **Project** | UDAY |
| **Module** | MM (Supplier / Business Partner) |
| **Program (report)** | `ZMM_VEND_MASTER` |
| **Transaction** | `ZMM_VEND_UPLOAD` |
| **Includes** | `ZMM_VEND_MASTER_TOP`, `_SCR`, `_CL`, `_FORMS` |
| **Package** | `ZMM_ABAP` |
| **Type of development** | Program enhancement |
| **Complexity** | Medium–High |
| **WRICEF number** | _<to be filled>_ |
| **Related FSD** | `FSD/30 FSD_ZMM_VEND_UPLOAD - upload program.doc` |
| **Change tag** | `"FSD30` |
| **TS Version** | 1.0 |
| **Prepared by** | _<developer>_ |
| **Date** | 2026-07-21 |

### Document revision history

| Date | Version | Description | Prepared by | Approved by |
|---|---|---|---|---|
| 2026-07-21 | 0.1 | Design draft based on FSD | | |
| 2026-07-21 | 1.0 | Reconciled with actual program source; implementation units defined | | |

---

## 1. Overview

`ZMM_VEND_MASTER` (tcode `ZMM_VEND_UPLOAD`) creates Supplier (Vendor) **Business
Partners** from an uploaded Excel file, and already contains an **Extend** path
(`rb_ext`) that adds Company-Code / Purchasing views via `vmd_ei_api`. This
enhancement (FSD 30) retains the working creation logic and adds:

1. **R1 — Error handling & processing log:** record-level Success/Warning/Error,
   row number, on-screen ALV log, and a **download of failed records only**.
2. **R2 — Auto-extension** of the created supplier to **Company Code** and
   **Purchasing Org** with **independent status per role** and **"already
   extended"** detection (the "role not extended" fix + safe re-upload of
   leftover data).
3. **R3 — Separate Change mode** (`rb_chg`): only file-populated fields updated;
   blank cells never overwrite master data; BP number mandatory.
4. **R4 — Validation & duplicate checks** (GST/PAN/Tax): invalid records skipped
   and logged; **one bad record never stops the batch**.

**Process flow (FSD):** Upload → Validate → Duplicate check → Create BP →
Extend Company Code → Extend Purch Org → Processing log → Download error log.

---

## 2. Baseline (as-is) findings

| Area | As-is in `ZMM_VEND_MASTER` |
|---|---|
| Selection screen (`_SCR`) | Radios `rb_new` / `rb_chg` / `rb_ext`; file `p_flname`; template button |
| Create | `create_bp_vendor` → `BAPI_BUPA_CREATE_FROM_DATA` (`call_bapi_bupa_create`) / `BAPI_BUPA_CENTRAL_CHANGE`; `add_vendor_roles` (FLVN00/FLVN01); CC+Purch via class `lcl_data`→`vmd_ei_api=>maintain_bapi` |
| Extend | `extend_bp` → `vmd_ei_api=>maintain_bapi` (CC via `LFB1`, Purch via `LFM1`, partner functions via `WYT3`) |
| Logs | `t_log` (`ty_log`), `t_log_ex` (`ty_log_ex`); ALV `display_log`/`display_log_ex`; full-log download |
| **Gaps vs FSD** | `msgty` never set on create; no row no.; download is *all* records; `PERFORM validations` commented out; `rb_chg` branch commented out; `change_bp_vendor` overwrites blanks; `extend_bp` does **`LEAVE LIST-PROCESSING`** on a bad BP (stops the whole run); no duplicate check |

---

## 3. Scope

**In scope:** the four FSD enhancements to `ZMM_VEND_MASTER` for Supplier BPs.
**Out of scope:** existing BP creation business rules/config, customer BPs,
authorization redesign (standard MM authorization), batch scheduling.

---

## 4. Solution design & change units

Delivered as clean, compile-ready units (see
`final draft/ZMM_VEND_MASTER_FSD30_changes.abap`), each tagged `"FSD30`.

### 4.1 Data dictionary (Unit 1 — `_TOP`)
Add three fields to **both** log structures `ty_log` and `ty_log_ex`:

| Field | Type | Purpose |
|---|---|---|
| `rowno` | `i` | R1 — row number in the uploaded file |
| `stat_cc` | `bapi_mtype` | R2 — Company-Code extension status (S/W/E) |
| `stat_po` | `bapi_mtype` | R2 — Purchasing-Org extension status (S/W/E) |

`msgty` (overall S/W/E) and `message` already exist on both structures.

### 4.2 Main flow (Unit 2 — `START-OF-SELECTION`)
```
rb_new : convert_data_cr → validate_create → create_bp_vendor
         → download_error_log_cr → display_log
rb_ext : convert_data_ex → extend_bp → download_error_log_ex → display_log_ex
rb_chg : convert_data_ex → validate_change → extend_bp (change-aware)
         → download_error_log_ex → display_log_ex
```

### 4.3 Validation — CREATE (Unit 3 — new `validate_create`)  [R4]
- Mandatory: `partn_grp`, `partn_cat`, `name_first`.
- Existence: `bukrs` in `T001`, `ekorg` in `T024E`.
- Duplicate (within file + DB): **GST** `stcd3` vs `DFKKBPTAXNUM`; **PAN**
  `j_1ipanno` within-file (DB-level PAN handling per **O4**).
- Invalid rows → `t_log` with `msgty='E'` and removed from `it_file` (not
  processed). Valid rows continue. **No hard stop.**

### 4.4 Validation — CHANGE (Unit 4 — new `validate_change`)  [R3/R4]
- `bpartner` mandatory; must exist in `BUT000` (ALPHA-converted).
- Invalid rows → `t_log_ex` (`msgty='E'`) and skipped; batch continues.

### 4.5 Extend / Change engine (Unit 5 — modified `extend_bp`)  [R2/R3]
Single routine shared by **Extend** (`rb_ext`) and **Change** (`rb_chg`):
- **(a) No hard stop** — a missing/invalid BP is logged (`msgty='E'`) and the
  loop `CONTINUE`s (replaces `MESSAGE … LEAVE LIST-PROCESSING`).
- **(b) "Already extended" detection** — pre-check `LFB1` (CC) and `LFM1`
  (Purch) for the linked vendor; if present set `stat_cc`/`stat_po = 'W'` with a
  message, and keep the update as `task='M'`. Enables **safe re-upload of
  leftover data** — existing roles warn, missing roles are added.
- **(c) Blank-safe (Change)** — each `datax-<field>` flag is set **only when the
  file field is populated**, so blank cells never overwrite master data.
- **(d) Separate status** — `stat_cc` / `stat_po` per role; overall `msgty` =
  worst of the role statuses; an extension **error does not clear** the per-role
  S/W flags (creation status stays independent per R2).
- Message text is mode-aware ("changed" vs "extended").

### 4.6 Create classification (Unit 6 — modified `create_bp_vendor`)  [R1/R2]
- Remove `DELETE it_file WHERE bukrs IS INITIAL` (no silent drop of rows without
  a company code).
- At end of each record set `rowno`, and classify: `msgty='E'` if BP not
  created; `stat_cc/stat_po` = `S`/`W` (W when the view was expected but the
  file field was blank, or the message carries a Fail/Error note); overall
  `msgty` = `S`/`W` accordingly.

### 4.7 ALV log (Unit 7 — modified `display_log`)  [R1]
Field catalogue per FSD: **Row No, BP Number (hotspot), Supplier Name, Status,
CC Ext., PO Ext., GST No., PAN No., Message.** `display_log_ex` similarly gains
`ROWNO`, `STAT_CC`, `STAT_PO`.

### 4.8 Error-only download (Units 8 & 9 — new)  [R1]
`download_error_log_cr` / `download_error_log_ex` build a subset where
`msgty CA 'EA'` and `GUI_DOWNLOAD` it; no-op with a message when there are none.

### 4.9 Selection screen (Unit 10 — `_SCR`)
No structural change; ensure `TEXT-003` labels `rb_chg` as **"Change"**. The old
`change_bp_vendor` form is **retired** (superseded by 4.5 + 4.4).

---

## 5. Objects touched / transport list

| Object | Type | New/Change |
|---|---|---|
| `ZMM_VEND_MASTER` (main) | Program | Change (Unit 2) |
| `ZMM_VEND_MASTER_TOP` | Include | Change (Unit 1) |
| `ZMM_VEND_MASTER_FORMS` | Include | Change (Units 3–9) |
| `ZMM_VEND_MASTER_SCR` | Include | Change (text only, Unit 10) |
| Transport request | Workbench TR | New |

Key standard objects reused: `BAPI_BUPA_CREATE_FROM_DATA`, `BAPI_BUPA_ROLE_ADD_2`
(FLVN00/FLVN01), `vmd_ei_api=>maintain_bapi`, `vmd_ei_api_check=>get_mand_partner_functions`;
tables `BUT000`, `CVI_VEND_LINK`, `LFA1`, `LFB1`, `LFM1`, `WYT3`, `T001`,
`T024E`, `DFKKBPTAXNUM`.

---

## 6. Messages (R1)

Categorized **S / W / E** (literal text used today; a message class can replace
literals per **O6**). Indicative:

| Type | Text |
|---|---|
| E | Mandatory field &1 missing (row &2) |
| E | Company Code &1 does not exist |
| E | Purch Org &1 does not exist |
| E | Duplicate GST/PAN &1 (within file / BP &2) |
| E | Change mode: BP number is mandatory |
| E | BP &1 does not exist |
| S | Vendor &1 extended/changed successfully |
| W | CC &1 already extended |
| W | Purch Org &1 already extended |

---

## 7. Error-handling strategy

- **Row isolation** — each record processed in its own LUW; failures logged,
  batch continues (removes the `LEAVE LIST-PROCESSING` stop).
- **Two-tier status** — creation vs CC vs Purch tracked separately (`stat_cc`,
  `stat_po`).
- **Safe re-upload** — "already extended" → Warning, not Error.

---

## 8. Security & authorization

Standard MM authorization applies — no new authorization objects (FSD §15).

---

## 9. Unit test cases (FSD §3.1 + additions)

| # | Test | Expected |
|---|---|---|
| UT-01 | Create valid record | BP created; `msgty='S'` |
| UT-02 | Extend Company Code | `LFB1` view; `stat_cc='S'` |
| UT-03 | Extend Purchasing Org | `LFM1` view; `stat_po='S'` |
| UT-04 | Log for success | Green row with BP number & row no. |
| UT-05 | Missing mandatory | Row skipped; `msgty='E'` |
| UT-06 | Invalid CC / Purch Org | Error message; row skipped |
| UT-07 | Duplicate GST/PAN | Not processed; duplicate error |
| UT-08 | Change valid | Only populated fields updated; `S` |
| UT-09 | Change blank field | Existing master data **not** overwritten |
| UT-10 | Mixed file (some fail) | Valid rows still processed |
| UT-11 | Download error log | File has failed records only |
| UT-12 | S/W/E categorization | Correct status columns |
| UT-13 | Re-upload leftover file | Existing roles → Warning; missing roles added |
| UT-14 | Extension fails, create OK | `msgty` create = S; `stat_cc/po = E` |

---

## 10. Open points (confirm before transport)

- **O4** Duplicate precedence (GST vs PAN vs Tax No.); is a DB-level PAN match an
  error or a warning?
- **O6** Use a message class instead of literal message text?
- File is assumed to carry valid, existing Company Code / Purch Org (FSD
  assumption) — validation warns rather than hard-fails where feasible.

---

## 11. Sign-off

| Role | Name | Date | Signature |
|---|---|---|---|
| Functional lead | | | |
| Technical lead | | | |
| Client approver | | | |
