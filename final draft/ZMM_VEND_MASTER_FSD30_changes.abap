*&---------------------------------------------------------------------*
*& FSD 30 - ZMM_VEND_UPLOAD (Program ZMM_VEND_MASTER) enhancement
*& Project : UDAY / Astral Limited   Module: MM
*& Related : FSD 30 FSD_ZMM_VEND_UPLOAD - upload program
*&---------------------------------------------------------------------*
*& DELIVERY NOTE
*&   The baseline source (initial draft) is an SE38 print listing, not
*&   clean compilable source. This file therefore delivers the changes
*&   as CLEAN, COMPILE-READY units with exact placement. Each unit is
*&   marked NEW or MODIFIED and carries the change tag  "FSD30  so the
*&   ABAPer can locate/merge it into the corresponding include.
*&   Routines not listed here are UNCHANGED from the initial draft.
*&
*& CHANGE TAG :  FSD30   (search this tag to find every change)
*& AUTHOR     :  <developer>          DATE: 21.07.2026
*&---------------------------------------------------------------------*
*& SCOPE (mapped to FSD sections)
*&   R1 (2.1) Error handling & processing log  -> msgty S/W/E, row no.,
*&            status columns, error-only download.
*&   R2 (2.1) Auto-extend Company Code + Purch Org, SEPARATE status,
*&            "already extended" detection (LFB1 / LFM1).
*&   R3 (2.3) Separate CHANGE mode - only populated fields updated,
*&            blanks never overwrite master data; BP number mandatory.
*&   R4 (2.1/2.4) Validation + duplicate checks (GST/PAN/Tax); invalid
*&            records skipped & logged; one bad record never stops the
*&            batch (removes LEAVE LIST-PROCESSING hard stop).
*&---------------------------------------------------------------------*


*&=====================================================================*
*&  UNIT 1  -  MODIFIED  -  Include ZMM_VEND_MASTER_TOP                 *
*&  Add status / row-number fields to the two log structures.          *
*&  Place: inside TYPES ty_log and ty_log_ex, after the INCLUDE TYPE.  *
*&=====================================================================*
* --- ty_log  (create log) : append these three fields --------------- "FSD30
*   TYPES: BEGIN OF ty_log.
*     INCLUDE TYPE ty_file_bp.
*   TYPES:   msgty   TYPE bapi_mtype,
*            message TYPE string,
              rowno   TYPE i,          "FSD30 R1 row number in file
              stat_cc TYPE bapi_mtype, "FSD30 R2 Company Code ext status
              stat_po TYPE bapi_mtype. "FSD30 R2 Purch Org  ext status
*   TYPES: END OF ty_log.

* --- ty_log_ex (extend/change log) : append the same three fields --- "FSD30
*   TYPES: BEGIN OF ty_log_ex.
*     INCLUDE TYPE ty_file_extend.
*   TYPES:   msgty   TYPE bapi_mtype,
*            message TYPE string,
              rowno   TYPE i,          "FSD30 R1
              stat_cc TYPE bapi_mtype, "FSD30 R2
              stat_po TYPE bapi_mtype. "FSD30 R2
*   TYPES: END OF ty_log_ex.


*&=====================================================================*
*&  UNIT 2  -  MODIFIED  -  Main program ZMM_VEND_MASTER               *
*&  START-OF-SELECTION : add validation, activate CHANGE mode, and     *
*&  route the error-only download. Replace the existing block.         *
*&=====================================================================*
START-OF-SELECTION.
  CLEAR: lv_flag.
  PERFORM upload_excel.

  IF rb_new = 'X'.
    PERFORM convert_data_cr.
    PERFORM validate_create.          "FSD30 R4 - validate & de-dup, drop bad rows
    PERFORM create_bp_vendor.
    IF t_log IS NOT INITIAL.
      PERFORM download_error_log_cr.  "FSD30 R1 - error-only download (no-op if none)
      PERFORM display_log.
    ENDIF.

  ELSEIF rb_ext = 'X'.
    PERFORM convert_data_ex.
    PERFORM extend_bp.                "FSD30 R2 - now per-record, no hard stop
    IF t_log_ex IS NOT INITIAL.
      PERFORM download_error_log_ex.  "FSD30 R1
      PERFORM display_log_ex.
    ENDIF.

  ELSEIF rb_chg = 'X'.                "FSD30 R3 - CHANGE mode activated
    PERFORM convert_data_ex.          "change file uses the extend template layout
    PERFORM validate_change.          "FSD30 R4 - BP mandatory & must exist
    PERFORM extend_bp.                "shared maintain routine (change-aware)
    IF t_log_ex IS NOT INITIAL.
      PERFORM download_error_log_ex.  "FSD30 R1
      PERFORM display_log_ex.
    ENDIF.
  ENDIF.


*&=====================================================================*
*&  UNIT 3  -  NEW  -  Include ZMM_VEND_MASTER_FORMS                   *
*&  FSD30 R4 : validation + duplicate check for CREATE mode.           *
*&  Invalid rows are logged (msgty 'E') and removed from it_file so    *
*&  they are never processed; valid rows continue. Batch never stops.  *
*&=====================================================================*
FORM validate_create.                                       "FSD30 R4
  DATA: lt_valid    TYPE STANDARD TABLE OF ty_file_bp,
        lt_seen_pan TYPE HASHED TABLE OF j_1ipanno WITH UNIQUE KEY table_line,
        lt_seen_gst TYPE HASHED TABLE OF stcd3     WITH UNIQUE KEY table_line,
        lv_row      TYPE i,
        lv_err      TYPE string.

  LOOP AT it_file INTO wa_file.
    lv_row = sy-tabix.
    CLEAR: lv_err, w_log.

    " --- mandatory fields (R4) ---
    IF wa_file-partn_grp IS INITIAL.
      lv_err = |{ lv_err }BP Grouping missing; |.
    ENDIF.
    IF wa_file-partn_cat IS INITIAL.
      lv_err = |{ lv_err }Partner Category missing; |.
    ENDIF.
    IF wa_file-name_first IS INITIAL.
      lv_err = |{ lv_err }Name1 missing; |.
    ENDIF.

    " --- master-data existence for the extension targets ---
    IF wa_file-bukrs IS NOT INITIAL.
      SELECT SINGLE bukrs FROM t001 INTO @DATA(lv_bukrs) WHERE bukrs = @wa_file-bukrs.
      IF sy-subrc <> 0.
        lv_err = |{ lv_err }Company Code { wa_file-bukrs } does not exist; |.
      ENDIF.
    ENDIF.
    IF wa_file-ekorg IS NOT INITIAL.
      SELECT SINGLE ekorg FROM t024e INTO @DATA(lv_ekorg) WHERE ekorg = @wa_file-ekorg.
      IF sy-subrc <> 0.
        lv_err = |{ lv_err }Purch Org { wa_file-ekorg } does not exist; |.
      ENDIF.
    ENDIF.

    " --- duplicate check : within file + against database (R4 / O4) ---
    " NOTE (O4): confirm precedence GST vs PAN vs Tax No. with functional.
    IF wa_file-stcd3 IS NOT INITIAL.
      IF line_exists( lt_seen_gst[ table_line = wa_file-stcd3 ] ).
        lv_err = |{ lv_err }Duplicate GST { wa_file-stcd3 } within file; |.
      ELSE.
        INSERT wa_file-stcd3 INTO TABLE lt_seen_gst.
        SELECT SINGLE partner FROM dfkkbptaxnum INTO @DATA(lv_ptnr)
               WHERE taxnum = @wa_file-stcd3.
        IF sy-subrc = 0.
          lv_err = |{ lv_err }GST { wa_file-stcd3 } already exists (BP { lv_ptnr }); |.
        ENDIF.
      ENDIF.
    ENDIF.
    IF wa_file-j_1ipanno IS NOT INITIAL.
      IF line_exists( lt_seen_pan[ table_line = wa_file-j_1ipanno ] ).
        lv_err = |{ lv_err }Duplicate PAN { wa_file-j_1ipanno } within file; |.
      ELSE.
        INSERT wa_file-j_1ipanno INTO TABLE lt_seen_pan.
      ENDIF.
    ENDIF.

    " --- verdict ---
    IF lv_err IS NOT INITIAL.
      w_log         = CORRESPONDING #( wa_file ).
      w_log-rowno   = lv_row.
      w_log-msgty   = 'E'.
      w_log-message = lv_err.
      APPEND w_log TO t_log.            "logged as failed, not processed
    ELSE.
      APPEND wa_file TO lt_valid.       "keep for processing
    ENDIF.
  ENDLOOP.

  it_file = lt_valid.                   "only valid rows go forward
ENDFORM.                                                    "FSD30 R4


*&=====================================================================*
*&  UNIT 4  -  NEW  -  Include ZMM_VEND_MASTER_FORMS                   *
*&  FSD30 R3/R4 : validation for CHANGE mode. BP number mandatory and  *
*&  must already exist. Bad rows logged & skipped; batch continues.    *
*&=====================================================================*
FORM validate_change.                                       "FSD30 R3/R4
  DATA: lt_valid TYPE STANDARD TABLE OF ty_file_extend,
        lv_row   TYPE i,
        lv_err   TYPE string,
        lv_bp    TYPE bu_partner.

  LOOP AT it_file_extend INTO wa_file_extend.
    lv_row = sy-tabix.
    CLEAR: lv_err.

    IF wa_file_extend-bpartner IS INITIAL.
      lv_err = 'Change mode: BP number is mandatory'.
    ELSE.
      lv_bp = |{ wa_file_extend-bpartner ALPHA = IN }|.
      SELECT SINGLE partner FROM but000 INTO @DATA(lv_x) WHERE partner = @lv_bp.
      IF sy-subrc <> 0.
        lv_err = |BP { wa_file_extend-bpartner } does not exist|.
      ENDIF.
    ENDIF.

    IF lv_err IS NOT INITIAL.
      CLEAR w_log_ex.
      w_log_ex         = CORRESPONDING #( wa_file_extend ).
      w_log_ex-rowno   = lv_row.
      w_log_ex-msgty   = 'E'.
      w_log_ex-message = lv_err.
      APPEND w_log_ex TO t_log_ex.
    ELSE.
      APPEND wa_file_extend TO lt_valid.
    ENDIF.
  ENDLOOP.

  it_file_extend = lt_valid.
ENDFORM.                                                    "FSD30 R3/R4


*&=====================================================================*
*&  UNIT 5  -  MODIFIED  -  Include ZMM_VEND_MASTER_FORMS  (extend_bp) *
*&  FSD30 R2/R3 : shared maintain routine used by EXTEND and CHANGE.   *
*&  Changes vs baseline:                                               *
*&   (a) NO hard stop - a missing/invalid BP is logged and the loop    *
*&       continues (baseline did MESSAGE + LEAVE LIST-PROCESSING).     *
*&   (b) "already extended" detection on LFB1 (CC) and LFM1 (Purch)    *
*&       -> Warning, kept SEPARATE from creation status (R2).          *
*&   (c) CHANGE-safe : each datax flag is set ONLY when the file field *
*&       is populated, so blank cells never overwrite master data (R3).*
*&   (d) per-role status stat_cc / stat_po + overall msgty S/W/E (R1). *
*&  Replace the whole baseline FORM extend_bp with the version below.  *
*&=====================================================================*
FORM extend_bp.                                             "FSD30 R2/R3
  DATA: lv_row     TYPE i,
        lv_mode_tx TYPE string.

  lv_mode_tx = COND #( WHEN rb_chg = 'X' THEN 'changed' ELSE 'extended' ). "R3

  LOOP AT it_file_extend INTO wa_file_extend.
    lv_row = sy-tabix.
    CLEAR: w_log_ex, l_partner, lv_vendor, businesspartner.
    MOVE-CORRESPONDING wa_file_extend TO w_log_ex.
    w_log_ex-rowno = lv_row.                                "R1

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING  input  = wa_file_extend-bpartner
      IMPORTING  output = wa_file_extend-bpartner.

    SELECT SINGLE partner FROM but000 INTO l_partner
           WHERE partner = wa_file_extend-bpartner.
    IF sy-subrc <> 0.
      " (a) no hard stop - log and carry on
      w_log_ex-msgty   = 'E'.
      w_log_ex-message = 'Please provide an existing BP number'.
      APPEND w_log_ex TO t_log_ex.
      CONTINUE.
    ENDIF.

    businesspartner = wa_file_extend-bpartner.
    SELECT SINGLE * FROM but000 INTO wa_but000
           WHERE partner = wa_file_extend-bpartner AND partner_guid NE ''.
    IF sy-subrc = 0.
      SELECT SINGLE vendor FROM cvi_vend_link INTO lv_vendor
             WHERE partner_guid = wa_but000-partner_guid.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
        REFRESH t_lfa1[].
        SELECT lifnr ktokk FROM lfa1 INTO TABLE t_lfa1 WHERE lifnr = lv_vendor.
      ENDIF.
    ENDIF.

    ls_vendors-header-object_instance-lifnr = lv_vendor.
    ls_vendors-header-object_task           = 'U'.

    "================= COMPANY CODE VIEW =================
    IF wa_file_extend-bukrs IS NOT INITIAL.
      REFRESH lt_company[].
      CLEAR ls_company.

      " (b) already-extended detection -> warning, separate status (R2)
      SELECT SINGLE bukrs FROM lfb1 INTO @DATA(lv_lfb1)
             WHERE lifnr = @lv_vendor AND bukrs = @wa_file_extend-bukrs.
      IF sy-subrc = 0.
        w_log_ex-stat_cc = 'W'.
        w_log_ex-message = |{ w_log_ex-message }CC { wa_file_extend-bukrs } already extended; |.
      ELSE.
        w_log_ex-stat_cc = 'S'.
      ENDIF.

      ls_company-task           = 'M'.
      ls_company-data_key-bukrs = wa_file_extend-bukrs.

      " (c) CHANGE-safe : fill data + set datax ONLY for populated fields
      IF wa_file_extend-akont IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING  input  = wa_file_extend-akont
          IMPORTING  output = ls_company-data-akont.
        ls_company-datax-akont = 'X'.
      ENDIF.
      IF wa_file_extend-zterm IS NOT INITIAL.
        ls_company-data-zterm = wa_file_extend-zterm.  ls_company-datax-zterm = 'X'.
      ENDIF.
      IF wa_file_extend-zuawa IS NOT INITIAL.
        ls_company-data-zuawa = wa_file_extend-zuawa.  ls_company-datax-zuawa = 'X'.
      ENDIF.
      IF wa_file_extend-mindk IS NOT INITIAL.
        ls_company-data-mindk = wa_file_extend-mindk.  ls_company-datax-mindk = 'X'.
      ENDIF.
      IF wa_file_extend-cerdt IS NOT INITIAL.
        ls_company-data-cerdt = |{ wa_file_extend-cerdt+6(4) }{ wa_file_extend-cerdt+3(2) }{ wa_file_extend-cerdt+0(2) }|.
        ls_company-datax-cerdt = 'X'.
      ENDIF.
      IF wa_file_extend-reprf IS NOT INITIAL.
        ls_company-data-reprf = wa_file_extend-reprf.  ls_company-datax-reprf = 'X'.
      ENDIF.

      APPEND ls_company TO ls_vendors-company_data-company.
    ENDIF.

    "================= PURCHASING VIEW =================
    IF wa_file_extend-ekorg IS NOT INITIAL.
      REFRESH: et_parvw[], lt_purchasing[], lt_purch_func[].
      CLEAR ls_purchasing.

      " (b) already-extended detection -> warning, separate status (R2)
      SELECT SINGLE ekorg FROM lfm1 INTO @DATA(lv_lfm1)
             WHERE lifnr = @lv_vendor AND ekorg = @wa_file_extend-ekorg.
      IF sy-subrc = 0.
        w_log_ex-stat_po = 'W'.
        w_log_ex-message = |{ w_log_ex-message }Purch Org { wa_file_extend-ekorg } already extended; |.
      ELSE.
        w_log_ex-stat_po = 'S'.
      ENDIF.

      ls_purchasing-task            = 'M'.
      ls_purchasing-data_key-ekorg  = wa_file_extend-ekorg.

      IF wa_file_extend-waers IS NOT INITIAL.
        ls_purchasing-data-waers = wa_file_extend-waers.  ls_purchasing-datax-waers = 'X'.
      ENDIF.
      IF wa_file_extend-zterm IS NOT INITIAL.
        ls_purchasing-data-zterm = wa_file_extend-zterm.  ls_purchasing-datax-zterm = 'X'.
      ENDIF.
      IF wa_file_extend-verkf IS NOT INITIAL.
        ls_purchasing-data-verkf = wa_file_extend-verkf.  ls_purchasing-datax-verkf = 'X'.
      ENDIF.
      IF wa_file_extend-telf1 IS NOT INITIAL.
        ls_purchasing-data-telf1 = wa_file_extend-telf1.  ls_purchasing-datax-telf1 = 'X'.
      ENDIF.
      IF wa_file_extend-ekgrp IS NOT INITIAL.
        ls_purchasing-data-ekgrp = wa_file_extend-ekgrp.  ls_purchasing-datax-ekgrp = 'X'.
      ENDIF.
      IF wa_file_extend-kalsk IS NOT INITIAL.
        ls_purchasing-data-kalsk = wa_file_extend-kalsk.  ls_purchasing-datax-kalsk = 'X'.
      ENDIF.
      " GR/Service-based IV kept as baseline defaults for the purchasing view
      ls_purchasing-data-lebre = 'X'.  ls_purchasing-datax-lebre = 'X'.
      ls_purchasing-data-webre = 'X'.  ls_purchasing-datax-webre = 'X'.

      CALL METHOD vmd_ei_api_check=>get_mand_partner_functions
        EXPORTING iv_ktokk = lfa1-ktokk
        IMPORTING et_parvw = et_parvw.

      LOOP AT et_parvw INTO DATA(wa_parvw).
        SELECT SINGLE parvw FROM wyt3 INTO @DATA(lv_pf_exists)
               WHERE lifnr = @lv_vendor AND ekorg = @wa_file_extend-ekorg
                 AND parvw = @wa_parvw-parvw.
        APPEND VALUE #(
          task     = COND #( WHEN lv_pf_exists IS NOT INITIAL THEN 'M' ELSE 'I' )
          data_key = VALUE #( parvw = wa_parvw-parvw )
          data     = VALUE #( partner = lv_vendor )
          datax    = VALUE #( partner = 'X' ) ) TO lt_purch_func.
      ENDLOOP.

      ls_purchasing-functions-functions = lt_purch_func[].
      APPEND ls_purchasing TO ls_vendors-purchasing_data-purchasing.
    ENDIF.

    APPEND ls_vendors TO gs_vmds_extern-vendors.

    vmd_ei_api=>initialize( ).
    CALL METHOD vmd_ei_api=>maintain_bapi
      EXPORTING is_master_data           = gs_vmds_extern
      IMPORTING es_master_data_correct   = gs_vmds_succ
                es_message_correct       = gs_succ_messages
                es_master_data_defective = gs_vmds_error
                es_message_defective     = gs_err_messages.

    IF gs_err_messages-is_error IS INITIAL.
      COMMIT WORK.
      WAIT UP TO 2 SECONDS.
      " overall status = worst of the per-role statuses (R1/R2)
      w_log_ex-msgty   = COND #( WHEN w_log_ex-stat_cc = 'W' OR w_log_ex-stat_po = 'W'
                                 THEN 'W' ELSE 'S' ).
      w_log_ex-message = |{ w_log_ex-message }Vendor { lv_vendor } { lv_mode_tx } successfully.|.
    ELSE.
      ROLLBACK WORK.
      w_log_ex-msgty = 'E'.
      " extension failure is recorded WITHOUT clearing per-role S/W flags (R2)
      LOOP AT gs_err_messages-messages INTO DATA(ls_msg).
        w_log_ex-message = COND #( WHEN w_log_ex-message IS INITIAL
                                   THEN ls_msg-message
                                   ELSE |{ w_log_ex-message } / { ls_msg-message }| ).
      ENDLOOP.
    ENDIF.
    APPEND w_log_ex TO t_log_ex.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
    REFRESH: lt_purch_func[],
             ls_vendors-company_data-company[],
             ls_vendors-purchasing_data-purchasing[],
             gs_vmds_extern-vendors[].
    CLEAR: wa_file_extend, gs_vmds_extern, ls_vendors, lv_vendor, businesspartner.
  ENDLOOP.
ENDFORM.                                                    "FSD30 R2/R3


*&=====================================================================*
*&  UNIT 6  -  MODIFIED  -  Include ZMM_VEND_MASTER_FORMS              *
*&  FSD30 R1/R2 : create_bp_vendor - two targeted changes only.       *
*&  The rest of the baseline form is UNCHANGED.                        *
*&=====================================================================*

* --- 6a. Do NOT silently drop rows without a company code. ----------- "FSD30 R2
*     BASELINE (remove):
*         it_file_all[] = it_file[].
*         DELETE it_file WHERE bukrs IS INITIAL.
*     REPLACE WITH:
      it_file_all[] = it_file[].
*     Keep every valid row; a missing company code is handled as a
*     warning during logging (below), not a silent delete.

* --- 6b. Set processing status + row number before APPEND w_log. ----- "FSD30 R1/R2
*     BASELINE tail of the loop:
*         ELSE.
*           w_log-message = |{ w_log-message }Vendor Creation Failed. |.
*         ENDIF.
*         APPEND w_log TO t_log.
*     REPLACE the "ELSE ... ENDIF. APPEND" with:
      ELSE.
        w_log-message = |{ w_log-message }Vendor Creation Failed. |.
      ENDIF.
      "--- FSD30 R1 : classify the record status ---
      w_log-rowno = sy-tabix.
      IF businesspartner IS INITIAL.
        w_log-msgty = 'E'.                       "creation failed
      ELSE.
        w_log-stat_cc = COND #( WHEN wa_file-bukrs IS INITIAL THEN 'W' ELSE 'S' ).
        w_log-stat_po = COND #( WHEN wa_file-ekorg IS INITIAL THEN 'W' ELSE 'S' ).
        " created OK; downgrade to W if a CC/PO view was expected but missing,
        " or if the message text carries a Fail/Error note from extension.
        IF w_log-message CS 'Fail' OR w_log-message CS 'ERROR'
           OR w_log-stat_cc = 'W' OR w_log-stat_po = 'W'.
          w_log-msgty = 'W'.
        ELSE.
          w_log-msgty = 'S'.
        ENDIF.
      ENDIF.
      APPEND w_log TO t_log.


*&=====================================================================*
*&  UNIT 7  -  MODIFIED  -  Include ZMM_VEND_MASTER_FORMS  (display_log)*
*&  FSD30 R1 : ALV columns per FSD - Row No, Supplier Name, BP Number, *
*&  Status, and Message. Replace the inline field catalogue only.      *
*&=====================================================================*
* --- Replace the lt_fcat VALUE( ... ) in FORM display_log with: ------ "FSD30 R1
  DATA(lt_fcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'ROWNO'      seltext_m = 'Row No.' )
    ( fieldname = 'BPARTNER'   seltext_m = 'BP Number'  hotspot = 'X' )
    ( fieldname = 'NAME_FIRST' seltext_m = 'Supplier Name' )
    ( fieldname = 'MSGTY'      seltext_m = 'Status' )
    ( fieldname = 'STAT_CC'    seltext_m = 'CC Ext.' )
    ( fieldname = 'STAT_PO'    seltext_m = 'PO Ext.' )
    ( fieldname = 'STCD3'      seltext_m = 'GST No.' )
    ( fieldname = 'J_1IPANNO'  seltext_m = 'PAN No.' )
    ( fieldname = 'MESSAGE'    seltext_m = 'Message' outputlen = 255 ) ).

* --- (Optional) same idea for FORM display_log_ex : add ROWNO, ------- "FSD30 R1
*     STAT_CC, STAT_PO columns alongside the existing BUKRS/EKORG/MSGTY.


*&=====================================================================*
*&  UNIT 8  -  NEW  -  Include ZMM_VEND_MASTER_FORMS                   *
*&  FSD30 R1 : error-only download for the CREATE log. Builds a subset *
*&  of failed records (msgty 'E'/'A') and downloads it. No-op with a   *
*&  message when there is nothing to download.                         *
*&=====================================================================*
FORM download_error_log_cr.                                 "FSD30 R1
  DATA: lt_err      LIKE t_log,
        lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  lt_err = VALUE #( FOR ls IN t_log WHERE ( msgty CA 'EA' ) ( ls ) ).
  IF lt_err IS INITIAL.
    MESSAGE 'No error records to download.' TYPE 'S'.
    RETURN.
  ENDIF.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING default_extension = 'XLS'
              default_file_name = |BP_Vendor_ERROR_Log_{ sy-datum }_{ sy-uzeit }.xls|
    CHANGING  filename = lv_filename
              path     = lv_path
              fullpath = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING filename              = lv_fullpath
                filetype              = 'ASC'
                write_field_separator = 'X'
                confirm_overwrite     = 'X'
      TABLES    data_tab              = lt_err
      EXCEPTIONS file_write_error = 1 OTHERS = 2.
    IF sy-subrc = 0.
      MESSAGE 'Error log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                                                    "FSD30 R1


*&=====================================================================*
*&  UNIT 9  -  NEW  -  Include ZMM_VEND_MASTER_FORMS                   *
*&  FSD30 R1 : error-only download for the EXTEND / CHANGE log.        *
*&=====================================================================*
FORM download_error_log_ex.                                 "FSD30 R1
  DATA: lt_err      LIKE t_log_ex,
        lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  lt_err = VALUE #( FOR ls IN t_log_ex WHERE ( msgty CA 'EA' ) ( ls ) ).
  IF lt_err IS INITIAL.
    MESSAGE 'No error records to download.' TYPE 'S'.
    RETURN.
  ENDIF.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING default_extension = 'XLS'
              default_file_name = |BP_Vendor_Ext_ERROR_Log_{ sy-datum }_{ sy-uzeit }.xls|
    CHANGING  filename = lv_filename
              path     = lv_path
              fullpath = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING filename              = lv_fullpath
                filetype              = 'ASC'
                write_field_separator = 'X'
                confirm_overwrite     = 'X'
      TABLES    data_tab              = lt_err
      EXCEPTIONS file_write_error = 1 OTHERS = 2.
    IF sy-subrc = 0.
      MESSAGE 'Error log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                                                    "FSD30 R1


*&=====================================================================*
*&  UNIT 10 -  NOTE  -  Include ZMM_VEND_MASTER_SCR (selection screen) *
*&  No structural change required: rb_new / rb_chg / rb_ext already    *
*&  exist. CHANGE mode (rb_chg) is now wired in UNIT 2. Ensure TEXT-003 *
*&  reads "Change" so the mode is clearly labelled to the user.        *
*&=====================================================================*

*&=====================================================================*
*&  RETIRED  -  FORM change_bp_vendor                                  *
*&  The baseline change_bp_vendor form (called nowhere, and which      *
*&  overwrote blank fields via a create-style flow) is superseded by   *
*&  the change-aware extend_bp (UNIT 5) + validate_change (UNIT 4).    *
*&  It can be deleted, or left dormant since it is not called.         *
*&=====================================================================*
