*&---------------------------------------------------------------------*
*& Report ZMM_VEND_MASTER
*&---------------------------------------------------------------------*
*       MODULE : Material Management                                   *
*----------------------------------------------------------------------*
*       Objective : VENDOR MASTER CREATE                               *
*       Program   : Updates Tables ( X )     Downloads data (  )       *
*                   Outputs List   (   )                               *
*                                                                      *
*                                                                      *
*       Date Created :    10.12.2025                                   *
*       Instructed by:    KPMG - Junaid Khan                           *
*       Devloped by:      KPMG - Jayprakash Tiwari                     *
*                                                                      *
*----------------------------------------------------------------------*
*       External Dependencies                                          *
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
* Amendment History                                                    *
*----------------------------------------------------------------------*
* Version Create/Change Owner     TR           CR/ID                   *
*......................................................................*
* <001>   Jayprakash Tiwari       DEVK900394                           *
* Reason: Mass vendor upload                                           *
*......................................................................*
* <002>                                                                *
* Reason:                                                              *
*----------------------------------------------------------------------*
REPORT zmm_vend_master.

INCLUDE zmm_vend_master_top.
INCLUDE zmm_vend_master_scr.
INCLUDE zmm_vend_master_cl.
INCLUDE zmm_vend_master_forms.

INITIALIZATION.
  " Setting button text and optional icon
  btn_tpl = '@49@ Download Template'.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'DTL'. " User-command assigned to the button
      PERFORM download_template.
  ENDCASE.

*&---------------------------------------------------------------------*
*&                    SEARCH HELP
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_flname.
  PERFORM value_request. "VALUE REQUEST FOR FILE
*&---------------------------------------------------------------------*
*&     START OF SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
****  PERFORM validations.
*&---------------------------------------------------------------------*
*&     CREATE BUSINESS PARTNER
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*BOC By Arnav on 21/07/2026
*  CLEAR : lv_flag.
*  PERFORM upload_excel.
*  IF rb_new = 'X'.
*    PERFORM convert_data_cr.
*    PERFORM create_bp_vendor.                        "CREATE BUSINESS PARTNER WITH VENDOR ROLES
*    IF t_log IS NOT INITIAL.
*      PERFORM download_log_to_excel. " Saves file first
*      PERFORM display_log.           " Then shows result on screen
*    ENDIF.
*  ELSEIF rb_ext = 'X'.
*    PERFORM convert_data_ex.
*    PERFORM extend_bp.
*    IF t_log_ex IS NOT INITIAL.
*      PERFORM download_log_to_excel_ex. " Saves file first
*      PERFORM display_log_ex.           " Then shows result on screen
*    ENDIF.
*****  ELSEIF rb_chg = 'X'.
*****    PERFORM convert_data_ex.
*****    PERFORM change_bp_vendor.
*  ENDIF.

  CLEAR: lv_flag.
  PERFORM upload_excel.

  IF rb_new = 'X'.
    PERFORM convert_data_cr.
    "Changes by Arnav on 22/07/26
    PERFORM validate_create.          "FSD30 R4 - validate & de-dup, drop bad rows
    PERFORM create_bp_vendor.
    IF t_log IS NOT INITIAL.
      "Changes by Arnav on 22/07/26
      PERFORM download_error_log_cr.  "FSD30 R1 - error-only download (no-op if none)
      PERFORM display_log.
    ENDIF.

  ELSEIF rb_ext = 'X'.
    PERFORM convert_data_ex.
    PERFORM extend_bp.                "FSD30 R2 - now per-record, no hard stop
    IF t_log_ex IS NOT INITIAL.
      "Changes by Arnav on 22/07/26
      PERFORM download_error_log_ex.  "FSD30 R1
      PERFORM display_log_ex.
    ENDIF.

  "Changes by Arnav on 22/07/26
  ELSEIF rb_chg = 'X'.                "FSD30 R3 - CHANGE mode activated
    PERFORM convert_data_ex.          "change file uses the extend template layout
    "Changes by Arnav on 22/07/26
    PERFORM validate_change.          "FSD30 R4 - BP mandatory & must exist
    PERFORM extend_bp.                "shared maintain routine (change-aware)
    IF t_log_ex IS NOT INITIAL.
      "Changes by Arnav on 22/07/26
      PERFORM download_error_log_ex.  "FSD30 R1
      PERFORM display_log_ex.
    ENDIF.
  ENDIF.
*BOC By Arnav on 21/07/2026
