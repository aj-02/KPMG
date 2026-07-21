*&---------------------------------------------------------------------*
*& WRICEF        : 195_BRD_FS_ZMB5B_Report
*& Project       : UDAY  /  Astral Limited
*& Module        : MM / CO
*& Object        : ZRM07MLBD  (copy of standard MB5B program RM07MLBD)
*& Transaction   : ZMB5B      (copy of standard MB5B)
*& Type          : Report enhancement (Medium)
*&---------------------------------------------------------------------*
*& REQUIREMENT (verbatim scope of FSD 195_BRD_FS)
*&   Copy the MB5B report program and create a new program.
*&   For radio button "Storage Loc./ Batch Stock", add an amount field
*&   in the report with respect to the material document:
*&   pass the material document (MSEG-MBLNR) and year (MSEG-MJAHR) and
*&   pick the value (MSEG-DMBTR).
*&
*&   Nothing beyond the above is implemented (no currency-key handling,
*&   no aggregation, no other columns) - none of that is advised in the
*&   FS.
*&---------------------------------------------------------------------*
*& KEY FINDING (from analysis of standard RM07MLBD)
*&   The value MSEG-DMBTR is ALREADY selected and ALREADY carried in the
*&   detail row - it is only hidden from display in the Storage Location
*&   view:
*&     * stype_mseg_lean holds  dmbtr LIKE mseg-dmbtr          (line 1184)
*&     * f0300_get_fields adds MSEG~DMBTR to the dynamic field list
*&     * f1000_select_mseg_mkpf selects it FROM matdoc in EVERY mode
*&       (keyed by MBLNR / MJAHR / ZEILE) - exactly the FS logic
*&     * fill_data_table MOVE-CORRESPONDING it onto the detail row
*&     * f0400_create_fieldcat only makes DMBTR visible when
*&       "IF NOT bwbst IS INITIAL" (valuated-stock mode)   <-- the gate
*&
*&   Therefore the ONLY change required is to make the already-present
*&   DMBTR column visible for the Storage Loc./Batch Stock (LGBST) view.
*&   No data retrieval / population change is needed.
*&---------------------------------------------------------------------*
*& HOW TO BUILD THE COPY  (as advised by the FS)
*&   Copy standard program RM07MLBD -> ZRM07MLBD together with its
*&   includes, renaming to Z equivalents and repointing the INCLUDE
*&   statements:
*&     RM07MLBD_CUST_FIELDS -> ZRM07MLBD_CUST_FIELDS
*&     RM07MLDD             -> ZRM07MLDD
*&     RM07MLBD_FORM_01     -> ZRM07MLBD_FORM_01
*&     RM07MLBD_FORM_02     -> ZRM07MLBD_FORM_02
*&   Create transaction ZMB5B for program ZRM07MLBD.
*&   Then apply the single change unit below. Line numbers refer to the
*&   standard RM07MLBD source listing used for analysis.
*&---------------------------------------------------------------------*


*&=====================================================================*
*& CHANGE UNIT (only change)  -  Show the amount column in the           *
*&                   Storage Loc./Batch Stock detail list               *
*&   Form   : f0400_create_fieldcat   (approx. line 4080)               *
*&   Anchor : the DMBTR block  "IF NOT bwbst IS INITIAL."               *
*&            (approx. line 4145)                                        *
*&   The radio buttons LGBST / BWBST / SBBST are one mutually-exclusive  *
*&   group, so "ELSEIF NOT lgbst IS INITIAL" adds the column for the     *
*&   Storage Loc./Batch Stock view only, exactly as the FS requests.    *
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

*  >>> ZMB5B 195_BRD_FS : add amount (MSEG-DMBTR) for Storage Loc./Batch
*      Stock radio button. Value is already on the row from MSEG
*      (MBLNR/MJAHR/ZEILE); only its display is enabled here.
     ELSEIF NOT lgbst IS INITIAL.
       g_s_fieldcat-fieldname     = 'DMBTR'.
       g_s_fieldcat-ref_tabname   = 'MSEG'.
       g_s_fieldcat-sp_group      = 'M'.
       PERFORM  f0410_fieldcat    USING  c_take   c_out.
*  <<< ZMB5B 195_BRD_FS
     ENDIF.


*&=====================================================================*
*& UNIT TEST (fills FSD section 3.1)                                    *
*&=====================================================================*
*&  1. Run ZMB5B, radio button "Storage Loc./Batch Stock", for a
*&     material/plant with goods movements in the date range ->
*&     detail list shows the amount (MSEG-DMBTR) column.
*&  2. Verify the amount per line equals MSEG-DMBTR of that material
*&     document item (cross-check in MB51 / table MSEG-MATDOC).
*&  3. Run the "Valuated Stock" radio button -> unchanged standard
*&     behaviour (regression check).
*&=====================================================================*
