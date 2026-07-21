*&---------------------------------------------------------------------*
*& WRICEF        : 195_BRD_FS_ZMB5B_Report
*& Project       : UDAY  /  Astral Limited
*& Module        : MM / CO
*& Object        : ZRM07MLBD  (copy of standard MB5B program RM07MLBD)
*& Transaction   : ZMB5B      (copy of standard MB5B)
*& Type          : Report enhancement (Medium)
*&---------------------------------------------------------------------*
*& REQUIREMENT
*&   In transaction MB5B, first radio button "Storage Location / Batch
*&   Stock" (parameter LGBST), add an AMOUNT column to the detail
*&   material-document list.  For each material document line the value
*&   is MSEG-DMBTR (amount in local / company-code currency), keyed by
*&   MSEG-MBLNR + MSEG-MJAHR (+ ZEILE).
*&
*& KEY FINDING (see analysis in repo)
*&   The value is ALREADY selected and ALREADY carried in the detail
*&   table - it is only hidden from display in LGBST mode:
*&     * stype_mseg_lean holds  dmbtr LIKE mseg-dmbtr          (line 1184)
*&     * f0300_get_fields adds MSEG~DMBTR to the dynamic field list
*&     * f1000_select_mseg_mkpf selects it FROM matdoc in EVERY mode
*&     * fill_data_table MOVE-CORRESPONDING it into the detail row
*&     * f0400_create_fieldcat only makes DMBTR visible when
*&       "IF NOT bwbst IS INITIAL" (valuated-stock mode)   <-- the gate
*&
*&   Therefore the enhancement = (1) show the amount for LGBST mode, and
*&   (2) pair it with the correct local (company-code) currency so the
*&   ALV currency formatting/label is right (MSEG-DMBTR is in local
*&   currency; MSEG-WAERS is the TRANSACTION currency and must NOT be
*&   used as the currency reference for DMBTR).
*&
*& HOW TO BUILD THE COPY
*&   Copy standard program RM07MLBD -> ZRM07MLBD together with its
*&   includes, renaming to Z equivalents and repointing the INCLUDE
*&   statements:
*&     RM07MLBD_CUST_FIELDS -> ZRM07MLBD_CUST_FIELDS
*&     RM07MLDD             -> ZRM07MLDD          (data declarations)
*&     RM07MLBD_FORM_01     -> ZRM07MLBD_FORM_01
*&     RM07MLBD_FORM_02     -> ZRM07MLBD_FORM_02
*&   Create transaction ZMB5B for program ZRM07MLBD.
*&   Then apply the four change units below.  Line numbers refer to the
*&   standard RM07MLBD source listing used for analysis.
*&
*& NOTE (design decisions applied)
*&   - Amount shown is LINE level (one row per material-doc item / ZEILE),
*&     which matches the per-item granularity of the detail list. If the
*&     business wants a per-document total, sum DMBTR by MBLNR+MJAHR
*&     instead (see CHANGE UNIT 4 - optional).
*&   - Local currency is read from MSEG-BUKRS via T001 (buffered).
*&---------------------------------------------------------------------*


*&=====================================================================*
*& CHANGE UNIT 1  -  Add the local-currency carrier field to the        *
*&                   detail output structure stype_belege               *
*&   Include : ZRM07MLDD   (copy of RM07MLDD)                            *
*&   Anchor  : TYPES BEGIN OF stype_belege ... (approx. line 1228)       *
*&   stype_belege is used by g_t_belege / g_t_belege1 / g_t_belege_uc.   *
*&   It is NOT scanned by f0300_get_fields (only g_s_mseg_lean is), so   *
*&   adding a field here has no effect on the dynamic MSEG SELECT.       *
*&=====================================================================*
*  --- BEFORE ---
*  TYPES : BEGIN OF stype_belege,
*            bwkey               LIKE      mbew-bwkey.
*            INCLUDE            TYPE      stype_mseg_lean.
*  TYPES :   farbe_pro_feld      TYPE slis_t_specialcol_alv,
*            farbe_pro_zeile(03) TYPE c.
*  TYPES : END OF stype_belege.
*
*  --- AFTER ---
   TYPES : BEGIN OF stype_belege,
             bwkey               LIKE      mbew-bwkey.
             INCLUDE            TYPE      stype_mseg_lean.
*  >>> ZMB5B 195_BRD_FS : local (company code) currency for DMBTR column
   TYPES :   hwaers              TYPE      waers.
*  <<< ZMB5B 195_BRD_FS
   TYPES :   farbe_pro_feld      TYPE slis_t_specialcol_alv,
             farbe_pro_zeile(03) TYPE c.
   TYPES : END OF stype_belege.


*&=====================================================================*
*& CHANGE UNIT 2  -  Populate the amount + local currency on every       *
*&                   storage-location detail row                         *
*&   Include : ZRM07MLBD_FORM_01   (copy of RM07MLBD_FORM_01)            *
*&   Form    : fill_data_table      (approx. line 3762)                  *
*&   Anchor  : immediately BEFORE  "APPEND l_s_belege TO l_t_belege."    *
*&             (approx. line 3817)                                       *
*&   fill_data_table is called ONLY in "bwbst IS INITIAL" mode (i.e.     *
*&   LGBST storage-loc/batch stock, and SBBST special stock), so this    *
*&   is the correct single choke point.  dmbtr is already present on     *
*&   l_s_belege via the preceding MOVE-CORRESPONDING.                    *
*&=====================================================================*
*  ... existing code ...
*        MOVE-CORRESPONDING g_s_mseg_lean
*                               TO  l_s_belege.
*
*        PERFORM  f9500_set_color_and_sign
*                         USING  l_s_belege  'L_S_BELEGE'.
*
*  >>> ZMB5B 195_BRD_FS : stamp local currency for the amount column
*      DMBTR is already in l_s_belege (local currency). Read the company
*      code currency so the ALV formats/labels the amount correctly.
         PERFORM z_get_local_currency USING    g_s_mseg_lean-bukrs
                                               g_s_mseg_lean-werks
                                      CHANGING l_s_belege-hwaers.
*  <<< ZMB5B 195_BRD_FS
*
*        APPEND  l_s_belege     TO  l_t_belege.
*  ... existing code ...


*&=====================================================================*
*& CHANGE UNIT 3  -  Make the amount visible in the detail field         *
*&                   catalog for the storage-location view               *
*&   Include : ZRM07MLBD  (main) or wherever f0400_create_fieldcat lives *
*&   Form    : f0400_create_fieldcat   (approx. line 4080)               *
*&   Anchor  : the DMBTR block  "IF NOT bwbst IS INITIAL."               *
*&             (approx. line 4145)                                       *
*&=====================================================================*
*  --- BEFORE ---
*    IF NOT bwbst IS INITIAL.            "mit bewertetem Bestand
*  *   Betrag in Hauswaehrung   Amount in local currency
*      g_s_fieldcat-fieldname     = 'DMBTR'.
*      g_s_fieldcat-ref_tabname   = 'BSIM'.
*      g_s_fieldcat-cfieldname    = 'WAERS'.
*      g_s_fieldcat-sp_group      = 'M'.
*      PERFORM  f0410_fieldcat    USING  c_take   c_out.
*    ENDIF.
*
*  --- AFTER ---
     IF NOT bwbst IS INITIAL.            "valuated stock (standard)
*    Betrag in Hauswaehrung   Amount in local currency
       g_s_fieldcat-fieldname     = 'DMBTR'.
       g_s_fieldcat-ref_tabname   = 'BSIM'.
       g_s_fieldcat-cfieldname    = 'WAERS'.
       g_s_fieldcat-sp_group      = 'M'.
       PERFORM  f0410_fieldcat    USING  c_take   c_out.

*  >>> ZMB5B 195_BRD_FS : show amount for Storage Loc./Batch Stock view
     ELSEIF NOT lgbst IS INITIAL.
*      Hidden currency reference field (local / company code currency)
       CLEAR g_s_fieldcat.
       g_s_fieldcat-fieldname     = 'HWAERS'.
       g_s_fieldcat-ref_tabname   = 'T001'.
       g_s_fieldcat-ref_fieldname = 'WAERS'.
       g_s_fieldcat-sp_group      = 'M'.
       PERFORM  f0410_fieldcat    USING  c_take   c_no_out.
*      Visible amount column, currency-referenced to HWAERS
       CLEAR g_s_fieldcat.
       g_s_fieldcat-fieldname     = 'DMBTR'.
       g_s_fieldcat-ref_tabname   = 'MSEG'.
       g_s_fieldcat-cfieldname    = 'HWAERS'.
       g_s_fieldcat-seltext_l     = 'Amount (Local Currency)'.
       g_s_fieldcat-seltext_m     = 'Amount (Loc.Cur.)'.
       g_s_fieldcat-seltext_s     = 'Amount'.
       g_s_fieldcat-ddictxt       = 'L'.
       g_s_fieldcat-sp_group      = 'M'.
       PERFORM  f0410_fieldcat    USING  c_take   c_out.
*  <<< ZMB5B 195_BRD_FS
     ENDIF.


*&=====================================================================*
*& CHANGE UNIT 4  -  New helper form: buffered local-currency lookup     *
*&   Include : ZRM07MLBD_FORM_01  (add at the end, before its last       *
*&             ENDFORM/EOF, alongside the other FORM routines)           *
*&=====================================================================*
*----------------------------------------------------------------------*
*  FORM z_get_local_currency
*     Returns the company-code (local) currency for a material-document
*     line. Primary key is BUKRS (MSEG-BUKRS = company code of the
*     movement, the currency in which DMBTR is stored). If BUKRS is not
*     populated on the record, it is derived from the plant (WERKS) via
*     the standard company-code-of-plant read. Result is buffered.
*----------------------------------------------------------------------*
FORM z_get_local_currency  USING    iv_bukrs TYPE bukrs
                                    iv_werks TYPE werks_d
                           CHANGING cv_waers TYPE waers.

* buffer of company code -> local currency
  STATICS: BEGIN OF lt_buf OCCURS 0,
             bukrs TYPE bukrs,
             waers TYPE waers,
           END OF lt_buf.
  STATICS: BEGIN OF lt_werks_buf OCCURS 0,
             werks TYPE werks_d,
             bukrs TYPE bukrs,
           END OF lt_werks_buf.

  DATA: lv_bukrs TYPE bukrs.

  CLEAR cv_waers.
  lv_bukrs = iv_bukrs.

* fallback: derive company code from plant if BUKRS is empty
  IF lv_bukrs IS INITIAL AND iv_werks IS NOT INITIAL.
    READ TABLE lt_werks_buf WITH KEY werks = iv_werks.
    IF sy-subrc = 0.
      lv_bukrs = lt_werks_buf-bukrs.
    ELSE.
*     T001K (valuation area = plant for standard config) -> BUKRS,
*     or T001W -> T001K. Use the standard helper: read via T001W-BWKEY.
      SELECT SINGLE bukrs FROM t001k
        INTO lv_bukrs
        WHERE bwkey = iv_werks.
      lt_werks_buf-werks = iv_werks.
      lt_werks_buf-bukrs = lv_bukrs.
      APPEND lt_werks_buf.
    ENDIF.
  ENDIF.

  CHECK lv_bukrs IS NOT INITIAL.

  READ TABLE lt_buf WITH KEY bukrs = lv_bukrs.
  IF sy-subrc = 0.
    cv_waers = lt_buf-waers.
  ELSE.
    SELECT SINGLE waers FROM t001
      INTO cv_waers
      WHERE bukrs = lv_bukrs.
    lt_buf-bukrs = lv_bukrs.
    lt_buf-waers = cv_waers.
    APPEND lt_buf.
  ENDIF.

ENDFORM.


*&=====================================================================*
*& CHANGE UNIT 4 (OPTIONAL)  -  Per-DOCUMENT amount instead of per-line  *
*&=====================================================================*
*&   The detail list shows one row per material-document ITEM (ZEILE),
*&   so DMBTR above is the per-item amount. If the business instead wants
*&   the amount summed per material document (MBLNR + MJAHR) shown on
*&   each row, replace the per-line stamp in CHANGE UNIT 2 with an
*&   aggregation. Sketch:
*&
*&   * After g_t_mseg_lean is fully filled (e.g. end of
*&     f1000_select_mseg_mkpf), build a summary buffer:
*&
*&       DATA: lt_docsum TYPE SORTED TABLE OF ...
*&                 WITH UNIQUE KEY mblnr mjahr.
*&       LOOP AT g_t_mseg_lean INTO g_s_mseg_lean.
*&         READ TABLE lt_docsum ... WITH KEY mblnr = ... mjahr = ...
*&         COLLECT dmbtr ...   (respecting SHKZG debit/credit sign)
*&       ENDLOOP.
*&
*&   * In fill_data_table, read lt_docsum by MBLNR+MJAHR and move the
*&     summed value into l_s_belege-dmbtr before APPEND.
*&
*&   Confirm with the functional lead whether line-level (default,
*&   implemented above) or document-level total is required, and how
*&   reversals (SHKZG = 'H') should be signed.
*&---------------------------------------------------------------------*

*&=====================================================================*
*& UNIT TEST CHECKLIST (fills FSD section 3.1)                          *
*&=====================================================================*
*&  1. Run ZMB5B, radio button "Storage Loc./Batch Stock", for a
*&     material/plant with goods movements in the date range ->
*&     detail list shows the new "Amount (Local Currency)" column.
*&  2. Verify the amount per line equals MSEG-DMBTR of that material
*&     document item (cross-check in MB51 / table MSEG/MATDOC).
*&  3. Verify the currency shown = company code currency of the plant
*&     (T001-WAERS for MSEG-BUKRS), including a plant whose transaction
*&     currency (MSEG-WAERS) differs from local currency.
*&  4. Run the "Valuated Stock" radio button -> unchanged standard
*&     behaviour (regression: DMBTR still shown, BSIM/WAERS).
*&  5. Run the "Special Stock" radio button -> amount also appears
*&     (SBBST is also bwbst-initial); confirm this is acceptable, else
*&     tighten CHANGE UNIT 3 condition to "ELSEIF NOT lgbst IS INITIAL
*&     AND sbbst IS INITIAL.".
*&  6. Export to Excel / save ALV layout with the new column.
*&=====================================================================*
