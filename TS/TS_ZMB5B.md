# Technical Specification (TS) — ZMB5B / ZRM07MLBD Stock Report Enhancement (FSD 195_BRD_FS)

| | |
|---|---|
| **Client** | Astral Limited |
| **Project** | UDAY |
| **Module** | MM / CO |
| **Program (report)** | `ZRM07MLBD` (copy of standard `RM07MLBD`) |
| **Transaction** | `ZMB5B` (copy of standard `MB5B`) |
| **Includes** | `RM07MLBD_CUST_FIELDS`, `RM07MLDD`, `RM07MLBD_FORM_01`, `RM07MLBD_FORM_02` (standard, referenced unchanged) |
| **Package** | _<to be filled>_ |
| **Type of development** | Report enhancement (copy of standard) |
| **Complexity** | Medium |
| **WRICEF number** | 195_BRD_FS_ZMB5B_Report |
| **Related FSD** | `FSD/195_BRD_FS_ZMB5B_Report.doc` |
| **Change tag** | `ZMB5B 195_BRD_FS` |
| **TS Version** | 1.0 |
| **Prepared by** | _<developer>_ |
| **Date** | 2026-07-22 |

### Document revision history

| Date | Version | Description | Prepared by | Approved by |
|---|---|---|---|---|
| 2026-07-22 | 1.0 | Initial TS reconciled with standard `RM07MLBD` source | | |

---

## 1. Overview

Standard transaction **MB5B** (program **RM07MLBD**) reports stock on a posting
date for various stock types chosen by radio button (Valuated Stock, Storage
Loc./Batch Stock, Special Stock). Per FSD 195_BRD_FS the program is **copied to
Z** (`ZRM07MLBD`, tcode `ZMB5B`) and enhanced so that, for the **"Storage Loc./
Batch Stock"** radio button, the detail list also shows the **amount**
(`MSEG-DMBTR`) against the material document.

**Key finding:** `MSEG-DMBTR` is *already* selected and carried on the detail row
in every mode (via `stype_mseg_lean` and `f1000_select_mseg_mkpf`, keyed by
`MBLNR` / `MJAHR` / `ZEILE`); it is only **hidden from display** in the Storage
Location view. Therefore the only functional change required is to make the
existing DMBTR column **visible** for that view — no data retrieval or
population change is needed.

**Process flow (unchanged):** Selection screen → data selection (MKPF/MSEG) →
field-catalog build → ALV output. The enhancement adds the DMBTR column to the
field catalog for the Storage Loc./Batch Stock view only.

---

## 2. Baseline (as-is) findings

| Area | As-is in `RM07MLBD` |
|---|---|
| Stock-type selection | Mutually-exclusive radios: `bwbst` (Valuated), `lgbst` (Storage Loc./Batch), `sbbst` (Special) |
| Amount field | `MSEG-DMBTR` present in `stype_mseg_lean`; selected in `f1000_select_mseg_mkpf` |
| Field catalog | `f0400_create_fieldcat` builds the columns; `f0410_fieldcat` appends each field |
| DMBTR visibility | Made visible **only** under `IF NOT bwbst IS INITIAL` (valuated-stock mode) |
| **Gap vs FSD** | DMBTR amount column not shown for the Storage Loc./Batch Stock (`lgbst`) view |

---

## 3. Scope

**In scope**

- Copy `RM07MLBD` → `ZRM07MLBD`; create transaction `ZMB5B`.
- Show the `MSEG-DMBTR` amount column for the Storage Loc./Batch Stock view.

**Out of scope** (not advised in the FS)

- Currency-key handling, aggregation, or any additional columns.
- Any change to data selection / population logic.
- Changes to the includes (they are unchanged from standard).

---

## 4. Solution design & change units

### 4.1 Copy to Z (Unit 1)

Copy the standard program to `ZRM07MLBD` and create transaction `ZMB5B`
(copy of `MB5B`). The program's `INCLUDE` statements continue to reference the
**standard** includes, which are unchanged:

| Standard object | Z equivalent |
|---|---|
| Program `RM07MLBD` | `ZRM07MLBD` |
| Transaction `MB5B` | `ZMB5B` |
| `RM07MLBD_CUST_FIELDS` | referenced as standard (unchanged) |
| `RM07MLDD` | referenced as standard (unchanged) |
| `RM07MLBD_FORM_01` | referenced as standard (unchanged) |
| `RM07MLBD_FORM_02` | referenced as standard (unchanged) |

### 4.2 Show amount column (Unit 2 — form `f0400_create_fieldcat`) — only functional change

Anchor: the DMBTR block `IF NOT bwbst IS INITIAL.` (≈ line 4145). Add an
`ELSEIF NOT lgbst IS INITIAL.` branch that appends the DMBTR column (reference
table `MSEG`) for the Storage Loc./Batch Stock view, then calls the standard
`f0410_fieldcat`. `lgbst` / `bwbst` / `sbbst` are one mutually-exclusive radio
group, so the `ELSEIF` targets the Storage Loc./Batch Stock view only.

```abap
    IF NOT bwbst IS INITIAL.            "valuated stock (standard)
      g_s_fieldcat-fieldname   = 'DMBTR'.
      g_s_fieldcat-ref_tabname = 'BSIM'.
      g_s_fieldcat-cfieldname  = 'WAERS'.
      g_s_fieldcat-sp_group    = 'M'.
      PERFORM f0410_fieldcat USING c_take c_out.
*  >>> ZMB5B 195_BRD_FS : show amount (MSEG-DMBTR) for Storage Loc./Batch Stock
    ELSEIF NOT lgbst IS INITIAL.
      g_s_fieldcat-fieldname   = 'DMBTR'.
      g_s_fieldcat-ref_tabname = 'MSEG'.
      g_s_fieldcat-sp_group    = 'M'.
      PERFORM f0410_fieldcat USING c_take c_out.
*  <<< ZMB5B 195_BRD_FS
    ENDIF.
```

The value is already on the detail row (selected from MSEG); only its display is
enabled here.

---

## 5. Objects touched / transport list

| Object | Type | New/Change |
|---|---|---|
| `ZRM07MLBD` (main) | Program | New copy + Change (Unit 2) |
| `RM07MLBD_CUST_FIELDS` | Include | Standard, referenced — no change |
| `RM07MLDD` | Include | Standard, referenced — no change |
| `RM07MLBD_FORM_01` | Include | Standard, referenced — no change |
| `RM07MLBD_FORM_02` | Include | Standard, referenced — no change |
| Tcode `ZMB5B` | Transaction | New |
| Transport request | Workbench TR | New |

Only the **main program** carries a functional change; the four includes are
unchanged from standard (0 changed lines, verified against the standard source).

---

## 6. Messages

No new messages. Standard MB5B messaging is retained.

---

## 7. Error-handling strategy

No new error handling. The added column reuses the existing field-catalog build
and ALV rendering; the amount value is already present on the detail row, so no
new selection or exception paths are introduced.

---

## 8. Security & authorization

Standard MB5B authorization applies — no new authorization objects. Transaction
`ZMB5B` to be assigned the same authorization group / roles as `MB5B`.

---

## 9. Unit test cases

| # | Test | Expected |
|---|---|---|
| UT-01 | Run `ZMB5B`, "Storage Loc./Batch Stock", material/plant with movements in the date range | Detail list shows the amount (`MSEG-DMBTR`) column |
| UT-02 | Cross-check a row's amount against `MSEG-DMBTR` (MB51 / table MSEG) for the same material-document item | Values match |
| UT-03 | Run the "Valuated Stock" radio button (regression) | Unchanged standard behaviour |
| UT-04 | Run the "Special Stock" radio button (regression) | Unchanged standard behaviour |

---

## 10. Open points (confirm before transport)

- Package and transport request assignment for the Z objects.
- The FSD suggests copying the includes to Z equivalents; as-built the Z program
  references the **standard** includes since they are unchanged — confirm this is
  acceptable, or copy the includes to Z as well.
- Whether transaction `ZMB5B` needs a dedicated authorization group.

---

## 11. Sign-off

| Role | Name | Date | Signature |
|---|---|---|---|
| Functional lead | | | |
| Technical lead | | | |
| Client approver | | | |
