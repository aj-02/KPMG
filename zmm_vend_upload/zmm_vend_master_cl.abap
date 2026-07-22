*&---------------------------------------------------------------------*
*& Include          ZMM_VEND_MASTER_CL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&                      CLASS DECLARATION
*&---------------------------------------------------------------------*
CLASS lcl_data DEFINITION.
  PUBLIC SECTION.
    METHODS: create_vendor_data.

  PRIVATE SECTION.
    METHODS: prepare_data
      RETURNING VALUE(re_flag) TYPE i.
*   DATA DECLARATIONS
    DATA: gs_vmds_extern   TYPE vmds_ei_main,
          gs_succ_messages TYPE cvis_message,
          gs_vmds_error    TYPE vmds_ei_main,
          gs_err_messages  TYPE cvis_message,
          gs_vmds_succ     TYPE vmds_ei_main,
          gv_ktokk         TYPE ktokk,
          gv_ccode         TYPE bukrs,
          gv_akont         TYPE akont,
          gv_name          TYPE name1.
ENDCLASS.                    "LCL_DATA
*----------------------------------------------------------------------*
*       CLASS LCL_DATA IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_data IMPLEMENTATION.
*&---------------------------------------------------------------------*
*&  METHOD TO CREATE VENDOR DATA
*&---------------------------------------------------------------------*
  METHOD create_vendor_data.
*   LOCAL DATA DECLARATION
    DATA: lv_return TYPE i.
*   PREPARE THE DATA TO BE USED FOR VENDOR CREATION
    lv_return =  me->prepare_data( ).
*   DO NOT PROCEED IF THE VENDOR DATA FOR CREATION WAS NOT PREPARED
    IF lv_return IS NOT INITIAL.
      EXIT.
    ENDIF.
*   INITIALIZE ALL THE DATA
    vmd_ei_api=>initialize( ).
*   CALL THE METHOD FOR CREATION OF VENDOR.
    CALL METHOD vmd_ei_api=>maintain_bapi
      EXPORTING
        is_master_data           = gs_vmds_extern
      IMPORTING
        es_master_data_correct   = gs_vmds_succ
        es_message_correct       = gs_succ_messages
        es_master_data_defective = gs_vmds_error
        es_message_defective     = gs_err_messages.

    IF gs_err_messages-is_error IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      w_log-message = |{ w_log-message } Vendor BAPI Failed:|.  "Changes by Arnav on 22/07/26
      LOOP AT gs_err_messages-messages INTO DATA(wa_err).
        w_log-message = |{ w_log-message } { wa_err-message };|.  "Changes by Arnav on 22/07/26
      ENDLOOP.
    ENDIF.
  ENDMETHOD.                    "CREATE_VENDOR_DATA
*&---------------------------------------------------------------------*
*&  METHOD TO PREPARE DATA FOR VENDOR CREATION
*&---------------------------------------------------------------------*
  METHOD prepare_data.
    DATA: lt_contacts       TYPE vmds_ei_contacts_t,
          ls_contacts       TYPE vmds_ei_contacts,
          lt_vendors        TYPE vmds_ei_extern_t,
          ls_vendors        TYPE vmds_ei_extern,
          ls_address        TYPE cvis_ei_address1,
          ls_addressdep     TYPE vmds_ei_central_addr,
          lt_company        TYPE vmds_ei_company_t,
          ls_company        TYPE vmds_ei_company,
          whtax_t           TYPE vmds_ei_wtax_type_t,
          whtax_s           TYPE vmds_ei_wtax_type,
          ls_company_data   TYPE vmds_ei_vmd_company,
          ls_purchas_data   TYPE vmds_ei_vmd_purchasing,
          lt_purchasing     TYPE vmds_ei_purchasing_t,
          lt_purchasing2    TYPE vmds_ei_purchasing2_t,
          ls_purchasing     TYPE vmds_ei_purchasing,
          ls_purchasing2    TYPE vmds_ei_purchasing2_s,
          lt_purch_func     TYPE vmds_ei_functions_t,
          ls_purch_func     TYPE vmds_ei_functions,
          ls_purch_fun_data TYPE vmds_ei_vmd_functions,
          ls_message        TYPE cvis_message,
          lv_contactid      TYPE bapicontact_01-contact,
          l_ktokk           TYPE ktokk,
          ls_lfa1           TYPE vmds_lfa1_s.

    DATA: lv_date_frmc     TYPE dats,
          lv_date_toc      TYPE dats,
          lv_file_frm_date TYPE string,
          lv_file_to_date  TYPE string.

    DATA: iv_ktokd TYPE ktokd,
          et_parvw TYPE cmds_parvw_t.

    DATA: lv_date_con  TYPE dats,
          lv_file_date TYPE string.

    wa_file-bpartner = |{ wa_file-bpartner ALPHA = IN }|.  "Changes by Arnav on 22/07/26

    CLEAR: gs_vmds_extern.

    ls_vendors-header-object_instance-lifnr = |{ lfa1-lifnr ALPHA = IN }|.  "Changes by Arnav on 22/07/26
    ls_vendors-header-object_task = 'U'.

    ls_addressdep-data-bahns = wa_file-bahns.
    ls_addressdep-datax-bahns = abap_true.
    APPEND ls_addressdep TO ls_vendors-central_data-central-central_addressdep-addressdep.

    ls_vendors-central_data-central = VALUE #(
      data = VALUE #(
        stenr     = wa_file-stenr
        profs     = wa_file-profs
        bahns     = wa_file-bahns
        j_1kftind = wa_file-j_1kftind
        j_1kftbus = wa_file-j_1kftbus
      )
      datax = VALUE #(
        stenr     = 'X'
        profs     = 'X'
        bahns     = 'X'
        j_1kftind = 'X'
        j_1kftbus = 'X'
      )
    ).

    ls_vendors-central_data-address = VALUE #(
      task = 'U'
      postal = VALUE #(
        data = VALUE #(
          name    = lfa1-name1
          country = lfa1-land1
        )
        datax = VALUE #(
          name    = 'X'
          country = 'X'
        )
      )
    ).
*&---------------------------------------------------------------------*
*&  *   SET THE COMPANY CODE AND GL ACCOUNT
*&---------------------------------------------------------------------*
    IF wa_file-bukrs IS NOT INITIAL.
      CLEAR w_lfa1.

      READ TABLE t_lfa1 INTO w_lfa1 WITH KEY lifnr = lfa1-lifnr.
      IF sy-subrc = 0.
        l_ktokk = w_lfa1-ktokk.
      ENDIF.

      ls_company = VALUE #(
        task       = 'M'
        data_key   = VALUE #( bukrs = wa_file-bukrs )
        data       = VALUE #(
          "Changes by Arnav on 22/07/26
          akont    = |{ wa_file-akont ALPHA = IN }| " Inline Alpha Conversion
          zuawa    = wa_file-zuawa
          altkn    = wa_file-altkn
          " Date conversion using functional style/string templates
          cerdt    = COND #( WHEN wa_file-cerdt IS NOT INITIAL THEN |{ wa_file-cerdt+6(4) }{ wa_file-cerdt+3(2) }{ wa_file-cerdt+0(2) }| ELSE '' )  "Changes by Arnav on 22/07/26
          reprf    = wa_file-reprf
          zterm    = wa_file-zterm
          kverm    = wa_file-kverm
          hbkid    = wa_file-hbkid
          mindk    = wa_file-mindk
          zwels    = wa_file-paymethod
        )
        datax      = VALUE #(
          zterm    = 'X' akont = 'X' zuawa = 'X' altkn = 'X'
          reprf    = 'X' kverm = 'X' hbkid = 'X' mindk = 'X'
          zwels    = 'X'
        )
      ).
      IF wa_file-srno IS NOT INITIAL.
        LOOP AT it_file_all INTO DATA(wa_file_all) WHERE srno = wa_file-srno.  "Changes by Arnav on 22/07/26
          whtax_s-task  = 'M'.
          whtax_s-data_key-witht  = wa_file_all-witht.
          whtax_s-data-wt_withcd  = wa_file_all-wt_withcd.
          whtax_s-data-wt_subjct  = wa_file_all-wt_subjct.
          whtax_s-data-wt_wtstcd  = wa_file_all-wt_wtstcd.
          whtax_s-data-wt_exnr    = wa_file_all-wt_exnr  .
          whtax_s-data-wt_exrt    = wa_file_all-wt_exrt.

          IF wa_file_all-wt_exdf IS NOT INITIAL.
            lv_file_frm_date = wa_file_all-wt_exdf.
            lv_date_frmc = lv_file_frm_date+6(4) && lv_file_frm_date+3(2) && lv_file_frm_date+0(2).
          ENDIF.
          IF wa_file_all-wt_exdt IS NOT INITIAL.
            lv_file_to_date = wa_file_all-wt_exdt .
            lv_date_toc = lv_file_to_date+6(4) && lv_file_to_date+3(2) && lv_file_to_date+0(2).
          ENDIF.

          whtax_s-data-wt_exdf    = lv_date_frmc.
          whtax_s-data-wt_exdt    = lv_date_toc .
          whtax_s-data-wt_wtexrs  = wa_file_all-wt_wtexrs.
          whtax_s-data-qsrec      = wa_file_all-qsrec.

          whtax_s-datax-wt_withcd  = abap_true.
          whtax_s-datax-wt_subjct  = abap_true.
          whtax_s-datax-wt_wtstcd  = abap_true.
          whtax_s-datax-wt_exnr    = abap_true.
          whtax_s-datax-wt_exrt    = abap_true.
          whtax_s-datax-wt_exdf    = abap_true.
          whtax_s-datax-wt_exdt    = abap_true.
          whtax_s-datax-wt_wtexrs  = abap_true.
          whtax_s-datax-qsrec      = abap_true.

          APPEND whtax_s TO whtax_t.
          CLEAR: whtax_s, wa_file_all.
        ENDLOOP.

        ls_company-wtax_type-wtax_type = whtax_t.
      ENDIF.

      APPEND ls_company TO ls_vendors-company_data-company.
    ENDIF.
*&---------------------------------------------------------------------*
*&  *   SET THE PURCHASING DATA
*&---------------------------------------------------------------------*
    IF wa_file-ekorg IS NOT INITIAL.
      vmd_ei_api_check=>get_mand_partner_functions(
        EXPORTING iv_ktokk = w_lfa1-ktokk
        IMPORTING et_parvw = et_parvw
      ).

      DATA: lt_existing_wyt3 TYPE TABLE OF wyt3.
      SELECT * FROM wyt3
        INTO TABLE lt_existing_wyt3
        WHERE lifnr = w_lfa1-lifnr
          AND ekorg = wa_file-ekorg.

      ls_purchasing = VALUE #(
        task     = 'M'
        data_key = VALUE #( ekorg = wa_file-ekorg )
        data     = VALUE #(
          waers   = wa_file-waers
          zterm   = wa_file-zterm_org
          verkf   = wa_file-verkf
          telf1   = wa_file-telf1
          ekgrp   = wa_file-ekgrp
          kalsk   = wa_file-kalsk
          lebre   = wa_file-lebre
          kzaut   = wa_file-kzaut
          inco1   = wa_file-inco1
          inco2_l = wa_file-inco1_l
          inco2   = wa_file-inco2
          inco3_l = wa_file-inco2_l
          webre   = wa_file-webre
          lfabc   = wa_file-lfabc
        )
        datax    = VALUE #(
          waers = 'X' zterm = 'X' verkf = 'X' telf1 = 'X' ekgrp = 'X'
          kalsk = 'X' lebre = 'X' kzaut = 'X' inco1 = 'X' inco2_l = 'X'
          inco2 = 'X' inco3_l = 'X' webre = 'X'
        )
      ).

      ls_purchasing-functions-functions = VALUE #( FOR wa IN et_parvw (
          task     = COND #( WHEN line_exists( lt_existing_wyt3[ parvw = wa-parvw ] )
                     THEN 'U'
                     ELSE 'I' )
          data_key = VALUE #( parvw = wa-parvw )
          data     = VALUE #( partner = w_lfa1-lifnr )
          datax    = VALUE #( partner = 'X' )
      ) ).

      APPEND ls_purchasing TO ls_vendors-purchasing_data-purchasing.
    ENDIF.

    APPEND ls_vendors TO gs_vmds_extern-vendors.

    MOVE wa_file-bpartner TO iv_partner.
    IF rb_new = 'X' AND wa_file-bankl IS NOT INITIAL.
      PERFORM upload_bank_to_bp.
    ENDIF.
  ENDMETHOD.                    "PREPARE_DATA
ENDCLASS.                    "LCL_DATA IMPLEMENTATION

DATA: lo_data TYPE REF TO lcl_data.
