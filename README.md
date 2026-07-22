# KPMG

ABAP development for two objects: **ZMM_VEND_UPLOAD** (mass vendor upload) and
**ZMB5B / ZRM07MLBD** (MB5B stock report enhancement).

The work is split across branches by content type:

| Branch | Contains |
|--------|----------|
| **main** | This overview only. |
| **documents** | Functional (`FSD/`) and technical (`TS/`) specification documents. |
| **draft-code** | Source material — `initial draft/`, `final draft/`, and `final code/`. |
| **claude** | Final per-object `.abap` files with change markers — `zmm_vend_upload/` and `zmb5b/`. |

Change markers in the delivered code use `*BOC/*EOC By Arnav on <date>` for
added blocks and `"Changes by Arnav on <date>` for single-line changes.
