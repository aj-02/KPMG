*&---------------------------------------------------------------------*
*& Report ZMM_VEND_MASTER  (tcode ZMM_VEND_UPLOAD)
*&---------------------------------------------------------------------*
*& MODULE     : Material Management
*& Objective  : VENDOR MASTER CREATE / EXTEND / CHANGE (mass upload)
*& Package    : ZMM_ABAP
*& Created    : 10.12.2025  KPMG - Jayprakash Tiwari  (DEVK900394)
*&---------------------------------------------------------------------*
*& COMPLETE SOURCE - all four existing includes reproduced in full,
*& re-spaced to clean ABAP. FSD 30 enhancements are inserted ONLY where
*& required; every change is marked with the tag  *FSD30 . No new
*& includes are introduced and no existing logic is restructured.
*&
*& FSD 30 change summary (see ZMM_VEND_MASTER_FSD30_changes.abap / TS):
*&   R1 processing log  : msgty S/W/E, row no., status columns, error-only
*&                        download (download_error_log_cr / _ex).
*&   R2 auto-extend CC + Purch Org : separate stat_cc/stat_po, "already
*&                        extended" detection (LFB1/LFM1).
*&   R3 separate Change mode (rb_chg) : blank-safe, BP number mandatory.
*&   R4 validation + duplicate (GST/PAN) : invalid rows skipped & logged,
*&                        no LEAVE LIST-PROCESSING hard stop.
*&---------------------------------------------------------------------*
REPORT zmm_vend_master.

INCLUDE zmm_vend_master_top.
INCLUDE zmm_vend_master_scr.
INCLUDE zmm_vend_master_cl.
INCLUDE zmm_vend_master_forms.

INITIALIZATION.
  " Setting button text and optional icon
  btn_tpl = '@49@Download Template'.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'DTL'.                     " User-command assigned to the button
      PERFORM download_template.
  ENDCASE.

*&---------------------------------------------------------------------*
*&  SEARCH HELP - VALUE REQUEST FOR FILE
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_flname.
  PERFORM value_request.

*&---------------------------------------------------------------------*
*&  START OF SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  CLEAR: lv_flag.
  PERFORM upload_excel.

  IF rb_new = 'X'.
    PERFORM convert_data_cr.
    PERFORM validate_create.          "*FSD30 R4 - validate & de-dup, drop bad rows
    PERFORM create_bp_vendor.         " CREATE BUSINESS PARTNER WITH VENDOR ROLES
    IF t_log IS NOT INITIAL.
      PERFORM download_error_log_cr.  "*FSD30 R1 - error-only download (no-op if none)
      PERFORM display_log.            " Then shows result on screen
    ENDIF.

  ELSEIF rb_ext = 'X'.
    PERFORM convert_data_ex.
    PERFORM extend_bp.
    IF t_log_ex IS NOT INITIAL.
      PERFORM download_error_log_ex.  "*FSD30 R1
      PERFORM display_log_ex.
    ENDIF.

  ELSEIF rb_chg = 'X'.                "*FSD30 R3 - CHANGE mode activated
    PERFORM convert_data_ex.          " change file uses the extend template layout
    PERFORM validate_change.          "*FSD30 R4 - BP mandatory & must exist
    PERFORM extend_bp.                " shared maintain routine (change-aware)
    IF t_log_ex IS NOT INITIAL.
      PERFORM download_error_log_ex.  "*FSD30 R1
      PERFORM display_log_ex.
    ENDIF.
  ENDIF.


*&=====================================================================*
*&  Include          ZMM_VEND_MASTER_TOP                               *
*&=====================================================================*
*  --- TABLES DECLARATION ---
TABLES: but000, lfa1, but020.

*  --- TYPES DECLARATION ---
TYPES: BEGIN OF ty_file_bp,
         bpartner    TYPE bu_partner,   "1  Business Partner Number
         partn_cat   TYPE bu_type,      "2  Partner Type (2=Org,1=Person)
         partn_grp   TYPE bu_group,     "3  BP Grouping
         title       TYPE ad_titletx,   "4  Title
         name_first  TYPE bu_nameor1,   "5  Name1
         name_last   TYPE bu_nameor2,   "6  Name2
         name_last2  TYPE bu_nameor3,   "7  Name3
         name_middle TYPE bu_nameor4,   "8  Name4
         zz_bu_old   TYPE char20,       "9  Old Vendor Code
         searchterm1 TYPE bu_sort1,     "10 Search Term1
         searchterm2 TYPE bu_sort2,     "11 Search Term2
         building    TYPE ad_bldng,     "12 BUILDING
         roomnumber  TYPE ad_roomnum,   "13 ROOMNUMBER
         floor       TYPE ad_floor,     "14 FLOOR
         street      TYPE ad_street,    "15 STREET
         str_suppl1  TYPE ad_strspp1,   "16 STREET1
         str_suppl2  TYPE ad_strspp2,   "17 STREET2
         str_suppl3  TYPE ad_strspp3,   "18 STREET3
         location    TYPE ad_lctn,      "19 LOCATION
         district    TYPE ad_city2,     "20 DISTRICT
         home_city   TYPE ad_city3,     "21 HOME CITY
         postl_cod1  TYPE ad_pstcd1,    "22 Postal Code
         city        TYPE ad_city1,     "23 City
         country     TYPE land1,        "24 Country
         region      TYPE regio,        "25 Region (General)
         tel_number  TYPE ad_tlnmbr,    "26 Telephone number
         mob_number  TYPE ad_tlnmbr,    "27 Mobile number
*        bpkind      TYPE bu_bpkind,    "28 (removed - sequence changed)
         fax         TYPE ad_fxnmbr,    "29 Fax Number
         smtp_addr   TYPE ad_smtpadr,   "30 Email0
         valid_from  TYPE string,       "31 Valid From (string; converted later)
         valid_to    TYPE string,       "32 Valid To   (string; converted later)
         partnertype TYPE bu_bpkind,    "33 Partner Type (free text from file)
         identificationcategory TYPE string, "34 Identification Category
         identificationnumber   TYPE string, "35 Identification Number
         id_from_date TYPE string,      "36 ID From Date (string; converted later)
         id_to_date   TYPE string,      "37 ID To Date   (string; converted later)
         tel_number_3 TYPE char10,      "38 Telephone no.3
         email_1     TYPE ad_smtpadr,   "39 Email1
         email_2     TYPE ad_smtpadr,   "40 Email2
         email_3     TYPE ad_smtpadr,   "41 Email3
         email_4     TYPE ad_smtpadr,   "42 Email4
         email_5     TYPE ad_smtpadr,   "42 Email5
         email_6     TYPE ad_smtpadr,   "42 Email6
         j_1iexcd    TYPE j_1iexcd,     "43 J1I Excise Dep#
         j_1iexrn    TYPE j_1iexrn,     "44 J1I Excise Range
         j_1iexrg    TYPE j_1iexrg,     "45 J1I Excise Division
         j_1iexdi    TYPE j_1iexdi,     "46 J1I Excise District
         j_1iexco    TYPE j_1iexco,     "47 J1I Excise Commissionerate
         j_1ivtyp    TYPE j_1ivtyp,     "48 J1I Vendor Type
         kunnr       TYPE kna1-kunnr,   "49 Customer Number
         j_1ipanno   TYPE j_1ipanno,    "50 PAN
         j_1isern    TYPE j_1isern,     "51 Service Tax Registration
         taxtype     TYPE dfkkbptaxnum-taxtype, "52 BP Tax Number Category
         stcd3       TYPE stcd3,        "53 GST No.
         ven_class   TYPE char10,       "54 Vendor Class
         isec        TYPE bus_bupa_industry_sectors-isec, "55 Industry Sector
         time_zone   TYPE char10,       "56 Time Zone
         " Company Code 57..65
         bukrs       TYPE lfb1-bukrs,   "57 Company Code
         akont       TYPE akont,        "58 Recon Account
         zuawa       TYPE dzuawa,       "59 Sort Key
         altkn       TYPE lfb1-altkn,   "60 Previous Account Number
         mindk       TYPE mindk,        "61 Minority Indicator
         cerdt       TYPE string,       "62 Certification Date (string; converted later)
         zterm       TYPE dzterm,       "63 Payment Terms
         reprf       TYPE reprf,        "64 Double Invoice Check
         kverm       TYPE kverm,        "65 Account Memo / Check Flag
         " Payment (House Bank ID) 66
         hbkid       TYPE hbkid,        "66 House Bank ID
         " Purchasing 67..87
         ekorg       TYPE ekorg,        "67 Purchasing Organization
         waers       TYPE waers,        "68 Currency
         zterm_org   TYPE dzterm,       "69 Payment Terms (Purchasing)
         verkf       TYPE verkf,        "70 Responsible Salesperson
         inco1       TYPE inco1,        "71 Incoterms Part1
         inco1_l     TYPE inco2_l,      "72 Incoterms Location1
         inco2       TYPE inco2,        "73 Incoterms Part2
         inco2_l     TYPE inco3_l,      "74 Incoterms Location2
         webre       TYPE webre,        "75 GR-based IV
         lebre       TYPE lebre,        "76 Service-based IV
         kzaut       TYPE kzaut,        "77 Automatic PO Allowed
         lfabc       TYPE lfabc,        "78 ABC Indicator
         stenr       TYPE stenr,        "79 TAN Number
         profs       TYPE profs,        "80 MSME Number
         j_1kftind   TYPE indtyp,       "81 Type of Industry
         j_1kftbus   TYPE gestyp,       "82 Type of Business
         bahns       TYPE bahns,        "83 Train Station (CIN)
         telf1       TYPE telf1,        "84 Supplier Telephone No.
         ekgrp       TYPE ekgrp,        "85 Purchasing Group
         kalsk       TYPE kalsk,        "86 Schema Group
         parvw       TYPE parvw,        "87 Partner Function (Purchasing override)
         " Payment/Bank 88..100
         banks       TYPE banks,        "88 Bank Country/Region Key
         bank_id     TYPE bu_bkvid,     "89 BP Bank ID
         bankl       TYPE bankl,        "90 Bank Key
         bankn       TYPE bankn,        "91 Bank Account Number
         bkref       TYPE bkref,        "92 Remaining Bank Account No.
         koinh       TYPE koinh_fi,     "93 Account Holder Name
         ebpp_accname TYPE ebpp_accname, "94 User-defined Bank Account Name
         banka       TYPE banka,        "95 Name of Financial Institution
         region_1    TYPE regio,        "96 Bank Region (second REGIO)
         street_1    TYPE bnka-stras,   "97 Bank Street
         city_1      TYPE ort01,        "98 Bank City
         brnch       TYPE brnch,        "99 Branch
         swift       TYPE bnka-swift,   "100 Swift Code
         " Other/Log/Keys 101..103
         reason      TYPE char100,      "101 Reason
         lifnr       TYPE lifnr,        "102 Vendor Number
         flag        TYPE c,            "103 Flag
         " Withholding 104..114
         srno        TYPE char4,        "104 WHT SRNO (group key)
         witht       TYPE witht,        "105 Withholding Tax Type
         wt_subjct   TYPE wt_subjct,    "106 Subject to WHT?
         qsrec       TYPE wt_qsrec,     "107 Type of Recipient
         wt_wtstcd   TYPE wt_wtstcd,    "108 WHT Identification Number
         wt_withcd   TYPE wt_withcd,    "109 WHT Code
         wt_exnr     TYPE wt_exnr,      "110 Exemption Certificate Number
         wt_exrt     TYPE wt_exrt,      "111 Exemption Rate
         wt_exdf     TYPE string,       "112 Exemption From Date
         wt_exdt     TYPE string,       "113 Exemption To Date
         wt_wtexrs   TYPE wt_wtexrs,    "114 Reason for Exemption
         paymethod   TYPE lfb1-zwels,   "115 Payment Method
         controlkey  TYPE lfbk-bkont,   "116 Control Key
       END OF ty_file_bp.

TYPES: BEGIN OF ty_log.
         INCLUDE TYPE ty_file_bp.
TYPES:   msgty   TYPE bapi_mtype,
         message TYPE string,
         rowno   TYPE i,               "*FSD30 R1 - row number in file
         stat_cc TYPE bapi_mtype,      "*FSD30 R2 - Company Code ext status
         stat_po TYPE bapi_mtype,      "*FSD30 R2 - Purch Org ext status
       END OF ty_log.

TYPES: BEGIN OF ty_file_extend,
         bpartner TYPE bu_partner,
         " COMPANY CODE DATA
         bukrs TYPE lfb1-bukrs,
         akont TYPE akont,             " RECON ACCOUNT
         zuawa TYPE dzuawa,            " SORT KEY
         mindk TYPE mindk,
         cerdt TYPE char10,            " CERDT
         zterm TYPE dzterm,
         reprf TYPE reprf,
         " PURCHASE ORGANISATION
         ekorg TYPE ekorg,
         waers TYPE waers,
         verkf TYPE verkf,
         telf1 TYPE telf1,
         ekgrp TYPE ekgrp,
         kalsk TYPE kalsk,
       END OF ty_file_extend.

TYPES: BEGIN OF ty_file_vendor,
         lifnr TYPE lifnr,
       END OF ty_file_vendor.

TYPES: BEGIN OF ty_lfa1,
         lifnr TYPE lfa1-lifnr,
         ktokk TYPE lfa1-ktokk,
       END OF ty_lfa1.

TYPES: BEGIN OF ty_upload,
         client   TYPE mandt,          " CLNT  30 CLIENT
         partner  TYPE bu_partner,     " CHAR  10 BUSINESS PARTNER NUMBER
         taxtype  TYPE bptaxtype,      " CHAR  40 TAX NUMBER CATEGORY
         taxnum   TYPE bptaxnum,       " CHAR  20 BUSINESS PARTNER TAX NUMBER
         taxnumxl TYPE bptaxnumxl,     " CHAR  60 BUSINESS PARTNER TAX NUMBER
       END OF ty_upload.

TYPES: BEGIN OF ty_msg,
         partner TYPE bu_partner,
         name    TYPE lfa1-name1,
         reason  TYPE string,
       END OF ty_msg.

TYPES: BEGIN OF ty_log_ex.
         INCLUDE TYPE ty_file_extend.
TYPES:   msgty   TYPE bapi_mtype,
         message TYPE string,
         rowno   TYPE i,               "*FSD30 R1
         stat_cc TYPE bapi_mtype,      "*FSD30 R2
         stat_po TYPE bapi_mtype,      "*FSD30 R2
       END OF ty_log_ex.

*  --- INTERNAL TABLE & WORK AREA DECLARATION ---
DATA: gt_raw     TYPE solix_tab,
      gv_bin_len TYPE i.
DATA: it_file        TYPE TABLE OF ty_file_bp,
      it_file_all    TYPE TABLE OF ty_file_bp,
      wa_file        TYPE ty_file_bp,
      t_error        TYPE TABLE OF ty_file_bp,
      t_log          TYPE TABLE OF ty_log,
      w_log          TYPE ty_log,
      t_log_ex       TYPE TABLE OF ty_log_ex,
      w_log_ex       TYPE ty_log_ex,
      t_msg          TYPE STANDARD TABLE OF ty_msg,
      w_msg          TYPE ty_msg,
      t_filev        TYPE TABLE OF ty_file_vendor,
      w_filev        TYPE ty_file_vendor,
      wa             TYPE ty_file_vendor,
      t_lfa1         TYPE STANDARD TABLE OF ty_lfa1,
      w_lfa1         TYPE ty_lfa1,
      it_raw         TYPE truxs_t_text_data,
      wa_bnka        TYPE bnka,
      wa_final_2     TYPE ty_upload,
      wa_final_3     TYPE lfb1,
      wa_final_5     TYPE lfm1,
      " Added for extend CC data & Pur.Org. Data
      it_file_extend TYPE STANDARD TABLE OF ty_file_extend,
      wa_file_extend TYPE ty_file_extend.

*  --- LOCAL AND GLOBAL VARIABLE DECLARATION ---
DATA: lv_flag,
      lv_vendor TYPE lfa1-lifnr,
      lv_length TYPE i.

*  --- LOCAL AND GLOBAL VARIABLE FOR ID NUMBER DECLARATION ---
DATA: lv_id_from_date  TYPE string,
      lv_id_to_date    TYPE string,
      lv1_id_from_date TYPE string,
      lv2_id_from_date TYPE string,
      lv1_id_to_date   TYPE string,
      lv2_id_to_date   TYPE string,
      lv1_identificationcategory TYPE bapibus1006_identification_key-identificationcategory,
      lv2_identificationcategory TYPE string,
      lv1_identificationnumber   TYPE bapibus1006_identification_key-identificationnumber,
      lv2_identificationnumber   TYPE string.

*  --- BP RELATED DATA DECLARATION ---
DATA: iv_partner       TYPE bu_partner,
      wa_but000        TYPE but000,
      wa_lfa1          TYPE lfa1,
      partner_change   TYPE flag,
      businesspartnerextern    TYPE bapibus1006_head-bpartner,
      partnercategory          TYPE bapibus1006_head-partn_cat,
      partnergroup             TYPE bapibus1006_head-partn_grp,
      centraldata              TYPE bapibus1006_central,
      centraldatax             TYPE bapibus1006_central_x,
      central_group            TYPE bapibus1006_central_group,
      central_groupx           TYPE bapibus1006_central_group_x,
      centraldataperson        TYPE bapibus1006_central_person,
      centraldatapersonx       TYPE bapibus1006_central_person_x,
      centraldataorganization  TYPE bapibus1006_central_organ,
      centraldataorganizationx TYPE bapibus1006_central_organ_x,
      centraldatagroup         TYPE bapibus1006_central_group,
      addressdata              TYPE bapibus1006_address,
      industries               TYPE bapibus1006_industrysector,
      businesspartner          TYPE bapibus1006_head-bpartner,
      it_telephondata          TYPE STANDARD TABLE OF bapiadtel,
      wa_telephondata          TYPE bapiadtel,
      it_maildata              TYPE STANDARD TABLE OF bapiadsmtp,
      wa_maildata              TYPE bapiadsmtp,
      industrysector           LIKE bapibus1006_industrysector-industrysector,
      identification           LIKE bapibus1006_identification,
      defaultindustry          LIKE bapibus1006_industrysector-defaultindustrysector,
      defaultindustry_x        LIKE bapibus1006_industrysector_x,
      industrysectorkeysystem  LIKE bapibus1006_industrysector-industrysectorkeysystem,
      industrysectordetail     TYPE STANDARD TABLE OF bapibus1006_industrysector,
      l_partner                TYPE bapibus1006_head-bpartner,
      it_faxdata               TYPE STANDARD TABLE OF bapiadfax,
      wa_faxdata               TYPE bapiadfax,
      return                   TYPE STANDARD TABLE OF bapiret2,
      x_save_add               TYPE bapi4001_1,
      chk_address              TYPE bapibus1006_address,
      businesspartnerrolecategory TYPE bapibus1006_bproles-partnerrolecategory,
      all_businesspartnerroles TYPE bapibus1006_x-mark,
      businesspartnerrole      TYPE bapibus1006_bproles-partnerrole,
      differentiationtypevalue TYPE bapibus1006_bproles-difftypevalue,
      validfromdate            TYPE bapibus1006_bprole_validity-bprolevalidfrom,
      validuntildate           TYPE bapibus1006_bprole_validity-bprolevalidto.

*  --- Company Code Extend Related DATA DECLARATION ---
DATA: lt_vendors      TYPE vmds_ei_extern_t,
      ls_vendors      TYPE vmds_ei_extern,
      ls_central      TYPE vmds_ei_vmd_central,
      lt_company      TYPE vmds_ei_company_t,
      ls_company      TYPE vmds_ei_company,
      ls_company_data TYPE vmds_ei_vmd_company,
      is_master_data  TYPE vmds_ei_main,
      ls_address      TYPE cvis_ei_address1,
      es_master_data_correct   TYPE vmds_ei_main,
      es_message_correct       TYPE cvis_message,
      es_master_data_defective TYPE vmds_ei_main,
      es_message_defective     TYPE cvis_message.

*  --- Purchasing Data Extend Related DATA DECLARATION ---
DATA: lt_purchasing     TYPE vmds_ei_purchasing_t,
      ls_purchasing     TYPE vmds_ei_purchasing,
      lt_purch_func     TYPE vmds_ei_functions_t,
      ls_purch_func     TYPE vmds_ei_functions,
      ls_purch_fun_data TYPE vmds_ei_vmd_functions,
      ls_purchas_data   TYPE vmds_ei_vmd_purchasing,
      iv_ktokd          TYPE ktokd,
      et_parvw          TYPE cmds_parvw_t.
DATA: gs_vmds_extern   TYPE vmds_ei_main,
      gs_succ_messages TYPE cvis_message,
      gs_vmds_error    TYPE vmds_ei_main,
      gs_err_messages  TYPE cvis_message,
      gs_vmds_succ     TYPE vmds_ei_main,
      gv_ktokk         TYPE ktokk,
      gv_ccode         TYPE bukrs,
      gv_akont         TYPE akont,
      gv_name          TYPE name1.

*  --- ALV RELATED DATA DECLARATION ---
DATA: t_fcat   TYPE slis_t_fieldcat_alv,
      w_fcat   TYPE slis_fieldcat_alv,
      s_layout TYPE slis_layout_alv.


*&=====================================================================*
*&  Include          ZMM_VEND_MASTER_SCR                               *
*&=====================================================================*
*  --- SELECTION SCREEN ---
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-101.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: rb_new RADIOBUTTON GROUP r1 USER-COMMAND uc1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(20) TEXT-001 FOR FIELD rb_new.
    PARAMETERS: rb_chg RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (40) TEXT-003 FOR FIELD rb_chg.   " TEXT-003 = 'Change'
    PARAMETERS: rb_ext RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (60) TEXT-002 FOR FIELD rb_ext.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-102.
  PARAMETERS: p_flname TYPE localfile.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-103.
  " Defining the button on the selection screen
  SELECTION-SCREEN PUSHBUTTON /2(25) btn_tpl USER-COMMAND dtl.
SELECTION-SCREEN: END OF BLOCK b3.


*&=====================================================================*
*&  Include          ZMM_VEND_MASTER_CL                                *
*&=====================================================================*
*  --- CLASS DECLARATION ---
CLASS lcl_data DEFINITION.
  PUBLIC SECTION.
    METHODS: create_vendor_data.
  PRIVATE SECTION.
    METHODS: prepare_data RETURNING VALUE(re_flag) TYPE i.
    " DATA DECLARATIONS
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

CLASS lcl_data IMPLEMENTATION.
*  --- METHOD TO CREATE VENDOR DATA ---
  METHOD create_vendor_data.
    " LOCAL DATA DECLARATION
    DATA: lv_return TYPE i.
    " PREPARE THE DATA TO BE USED FOR VENDOR CREATION
    lv_return = me->prepare_data( ).
    " DO NOT PROCEED IF THE VENDOR DATA FOR CREATION WAS NOT PREPARED
    IF lv_return IS NOT INITIAL.
      EXIT.
    ENDIF.
    " INITIALIZE ALL THE DATA
    vmd_ei_api=>initialize( ).
    " CALL THE METHOD FOR CREATION OF VENDOR.
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
      w_log-message = |{ w_log-message }Vendor BAPI Failed:|.
      LOOP AT gs_err_messages-messages INTO DATA(wa_err).
        w_log-message = |{ w_log-message }{ wa_err-message };|.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.                    "CREATE_VENDOR_DATA

*  --- METHOD TO PREPARE DATA FOR VENDOR CREATION ---
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

    wa_file-bpartner = |{ wa_file-bpartner ALPHA = IN }|.

    CLEAR: gs_vmds_extern.

    ls_vendors-header-object_instance-lifnr = |{ lfa1-lifnr ALPHA = IN }|.
    ls_vendors-header-object_task = 'U'.

    ls_addressdep-data-bahns  = wa_file-bahns.
    ls_addressdep-datax-bahns = abap_true.
    APPEND ls_addressdep TO ls_vendors-central_data-central-central_addressdep-addressdep.

    ls_vendors-central_data-central = VALUE #(
      data = VALUE #(
        stenr     = wa_file-stenr
        profs     = wa_file-profs
        bahns     = wa_file-bahns
        j_1kftind = wa_file-j_1kftind
        j_1kftbus = wa_file-j_1kftbus )
      datax = VALUE #(
        stenr     = 'X'
        profs     = 'X'
        bahns     = 'X'
        j_1kftind = 'X'
        j_1kftbus = 'X' ) ).

    ls_vendors-central_data-address = VALUE #(
      task = 'U'
      postal = VALUE #(
        data  = VALUE #( name = lfa1-name1 country = lfa1-land1 )
        datax = VALUE #( name = 'X'         country = 'X' ) ) ).

*  --- SET THE COMPANY CODE AND GL ACCOUNT ---
    IF wa_file-bukrs IS NOT INITIAL.
      CLEAR w_lfa1.
      READ TABLE t_lfa1 INTO w_lfa1 WITH KEY lifnr = lfa1-lifnr.
      IF sy-subrc = 0.
        l_ktokk = w_lfa1-ktokk.
      ENDIF.

      ls_company = VALUE #(
        task     = 'M'
        data_key = VALUE #( bukrs = wa_file-bukrs )
        data     = VALUE #(
          akont = |{ wa_file-akont ALPHA = IN }|   " Inline Alpha Conversion
          zuawa = wa_file-zuawa
          altkn = wa_file-altkn
          cerdt = COND #( WHEN wa_file-cerdt IS NOT INITIAL
                          THEN |{ wa_file-cerdt+6(4) }{ wa_file-cerdt+3(2) }{ wa_file-cerdt+0(2) }| ELSE '' )
          reprf = wa_file-reprf
          zterm = wa_file-zterm
          kverm = wa_file-kverm
          hbkid = wa_file-hbkid
          mindk = wa_file-mindk
          zwels = wa_file-paymethod )
        datax    = VALUE #(
          zterm = 'X' akont = 'X' zuawa = 'X' altkn = 'X'
          reprf = 'X' kverm = 'X' hbkid = 'X' mindk = 'X'
          zwels = 'X' ) ).

      IF wa_file-srno IS NOT INITIAL.
        LOOP AT it_file_all INTO DATA(wa_file_all) WHERE srno = wa_file-srno.
          whtax_s-task            = 'M'.
          whtax_s-data_key-witht  = wa_file_all-witht.
          whtax_s-data-wt_withcd  = wa_file_all-wt_withcd.
          whtax_s-data-wt_subjct  = wa_file_all-wt_subjct.
          whtax_s-data-wt_wtstcd  = wa_file_all-wt_wtstcd.
          whtax_s-data-wt_exnr    = wa_file_all-wt_exnr.
          whtax_s-data-wt_exrt    = wa_file_all-wt_exrt.
          IF wa_file_all-wt_exdf IS NOT INITIAL.
            lv_file_frm_date = wa_file_all-wt_exdf.
            lv_date_frmc = lv_file_frm_date+6(4) && lv_file_frm_date+3(2) && lv_file_frm_date+0(2).
          ENDIF.
          IF wa_file_all-wt_exdt IS NOT INITIAL.
            lv_file_to_date = wa_file_all-wt_exdt.
            lv_date_toc = lv_file_to_date+6(4) && lv_file_to_date+3(2) && lv_file_to_date+0(2).
          ENDIF.
          whtax_s-data-wt_exdf   = lv_date_frmc.
          whtax_s-data-wt_exdt   = lv_date_toc.
          whtax_s-data-wt_wtexrs = wa_file_all-wt_wtexrs.
          whtax_s-data-qsrec     = wa_file_all-qsrec.
          whtax_s-datax-wt_withcd = abap_true.
          whtax_s-datax-wt_subjct = abap_true.
          whtax_s-datax-wt_wtstcd = abap_true.
          whtax_s-datax-wt_exnr   = abap_true.
          whtax_s-datax-wt_exrt   = abap_true.
          whtax_s-datax-wt_exdf   = abap_true.
          whtax_s-datax-wt_exdt   = abap_true.
          whtax_s-datax-wt_wtexrs = abap_true.
          whtax_s-datax-qsrec     = abap_true.
          APPEND whtax_s TO whtax_t.
          CLEAR: whtax_s, wa_file_all.
        ENDLOOP.
        ls_company-wtax_type-wtax_type = whtax_t.
      ENDIF.

      APPEND ls_company TO ls_vendors-company_data-company.
    ENDIF.

*  --- SET THE PURCHASING DATA ---
    IF wa_file-ekorg IS NOT INITIAL.
      vmd_ei_api_check=>get_mand_partner_functions(
        EXPORTING iv_ktokk = w_lfa1-ktokk
        IMPORTING et_parvw = et_parvw ).

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
          lfabc   = wa_file-lfabc )
        datax    = VALUE #(
          waers = 'X' zterm = 'X' verkf = 'X' telf1 = 'X' ekgrp = 'X'
          kalsk = 'X' lebre = 'X' kzaut = 'X' inco1 = 'X' inco2_l = 'X'
          inco2 = 'X' inco3_l = 'X' webre = 'X' ) ).

      ls_purchasing-functions-functions = VALUE #( FOR wa IN et_parvw (
        task     = COND #( WHEN line_exists( lt_existing_wyt3[ parvw = wa-parvw ] )
                           THEN 'U' ELSE 'I' )
        data_key = VALUE #( parvw = wa-parvw )
        data     = VALUE #( partner = w_lfa1-lifnr )
        datax    = VALUE #( partner = 'X' ) ) ).

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


*&=====================================================================*
*&  Include          ZMM_VEND_MASTER_FORMS                             *
*&=====================================================================*
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
FORM download_template.
  DATA: lv_filename  TYPE string,
        lt_file_data TYPE TABLE OF string,
        lv_header    TYPE string,
        lv_fname     TYPE string,
        lv_path      TYPE string,
        lv_fpath     TYPE string,
        lv_action    TYPE i.

  " Add your specific field list here
  DATA(lv_tab) = cl_abap_char_utilities=>horizontal_tab.

  IF rb_new = 'X'.
    lv_header =
      |Business Partner Number{ lv_tab }Partner Type{ lv_tab }BP Grouping{ lv_tab }Title{ lv_tab }| &&
      |Name1{ lv_tab }Name2{ lv_tab }Name3{ lv_tab }Name4{ lv_tab }| &&
      |Old Vendor Code{ lv_tab }Search Term1{ lv_tab }Search Term2{ lv_tab }BUILDING{ lv_tab }| &&
      |ROOMNUMBER{ lv_tab }FLOOR{ lv_tab }STREET{ lv_tab }STREET1{ lv_tab }| &&
      |STREET2{ lv_tab }STREET3{ lv_tab }LOCATION{ lv_tab }DISTRICT{ lv_tab }| &&
      |HOMECITY{ lv_tab }Postal Code{ lv_tab }City{ lv_tab }Country{ lv_tab }| &&
      |Region (General){ lv_tab }Telephone number{ lv_tab }Mobile number{ lv_tab }Fax Number{ lv_tab }| &&
      |Email0{ lv_tab }Valid From{ lv_tab }Valid To{ lv_tab }Partner Type{ lv_tab }| &&
      |Identification Category{ lv_tab }Identification Number{ lv_tab }ID From Date{ lv_tab }ID To Date{ lv_tab }| &&
      |Telephone no.3{ lv_tab }Email1{ lv_tab }Email2{ lv_tab }Email3{ lv_tab }| &&
      |Email4{ lv_tab }Email5{ lv_tab }Email6{ lv_tab }J1I Excise-Dep{ lv_tab }J1I Excise-Range{ lv_tab }J1I Excise-Division{ lv_tab }| &&
      |J1I Excise-District{ lv_tab }J1I Excise-Commissionerate{ lv_tab }J1I Vendor Type{ lv_tab }Customer Number{ lv_tab }| &&
      |PAN{ lv_tab }Service Tax Registration{ lv_tab }BP Tax Number Category{ lv_tab }GST No.{ lv_tab }| &&
      |Vendor Class{ lv_tab }Industry Sector{ lv_tab }Time Zone{ lv_tab }Company Code{ lv_tab }| &&
      |Recon Account{ lv_tab }Sort Key{ lv_tab }Previous Account Number{ lv_tab }Minority Indicator{ lv_tab }| &&
      |Certification Date{ lv_tab }Payment Terms{ lv_tab }Double Invoice Check{ lv_tab }Account Memo/Check Flag{ lv_tab }| &&
      |NEW: House Bank ID{ lv_tab }Purchasing Organization{ lv_tab }Currency{ lv_tab }Payment Terms (Purchasing){ lv_tab }| &&
      |Responsible Salesperson{ lv_tab }Incoterms Part1{ lv_tab }Incoterms Location1{ lv_tab }Incoterms Part2{ lv_tab }| &&
      |Incoterms Location2{ lv_tab }GR-based IV{ lv_tab }Service-based IV{ lv_tab }Automatic PO Allowed{ lv_tab }| &&
      |ABC Indicator{ lv_tab }TAN Number{ lv_tab }MSME Number{ lv_tab }Type of Industry{ lv_tab }| &&
      |Type of Business{ lv_tab }Train Station (CIN){ lv_tab }Supplier Telephone No.{ lv_tab }Purchasing Group{ lv_tab }| &&
      |Schema Group{ lv_tab }Partner Function (Purchasing override){ lv_tab }Bank Country/Region Key{ lv_tab }BP Bank ID{ lv_tab }| &&
      |Bank Key{ lv_tab }Bank Account Number{ lv_tab }Remaining Bank Account No.{ lv_tab }Account Holder Name{ lv_tab }| &&
      |User-defined Bank Account Name{ lv_tab }Name of Financial Institution{ lv_tab }Bank Region{ lv_tab }Bank Street{ lv_tab }| &&
      |Bank City{ lv_tab }Branch{ lv_tab }Swift Code{ lv_tab }Reason{ lv_tab }| &&
      |Vendor Number{ lv_tab }Flag{ lv_tab }WHT SRNO (group key){ lv_tab }Withholding Tax Type{ lv_tab }| &&
      |Subject to WHT{ lv_tab }Type of Recipient{ lv_tab }WHT Identification Number{ lv_tab }WHT Code{ lv_tab }| &&
      |Exemption Certificate Number{ lv_tab }Exemption Rate{ lv_tab }Exemption From Date{ lv_tab }Exemption To Date{ lv_tab }| &&
      |Reason for Exemption{ lv_tab }Payment Method{ lv_tab }Control Key|.
  ELSEIF rb_ext = 'X' OR rb_chg = 'X'.
    lv_header =
      |Business Partner Number{ lv_tab }Company Code{ lv_tab }Recon Account{ lv_tab }| &&
      |Sort Key{ lv_tab }Minority Indicator{ lv_tab }Certification Date{ lv_tab }| &&
      |Payment Terms{ lv_tab }Double Invoice Check{ lv_tab }Purchasing Org{ lv_tab }| &&
      |Currency{ lv_tab }Responsible Salesperson{ lv_tab }Vendor Tel{ lv_tab }| &&
      |Purchasing Group{ lv_tab }Schema Group|.
  ENDIF.
  APPEND lv_header TO lt_file_data.

  " Open Save Dialog
  lv_filename = |BP_Vend_Template_{ sy-datum }_{ sy-uzeit }|.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Save Template As'
      default_extension = 'XLS'
      default_file_name = lv_filename
      initial_directory = 'C:\'
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fpath
      user_action       = lv_action.

  CHECK lv_action = cl_gui_frontend_services=>action_ok.

  " Download Header only (empty data table)
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename              = lv_fpath
      filetype              = 'DAT'
      write_field_separator = 'X'          " Ensures Excel columns align
    TABLES
      data_tab              = lt_file_data.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM value_request.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name = sy-cprog
    IMPORTING
      file_name    = p_flname.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_EXCEL
*&---------------------------------------------------------------------*
FORM upload_excel.
  DATA: lv_fname TYPE string.

  lv_fname = p_flname.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_fname
      filetype                = 'BIN'
    IMPORTING
      filelength              = gv_bin_len
    TABLES
      data_tab                = gt_raw
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATA_CR
*&---------------------------------------------------------------------*
FORM convert_data_cr.
  DATA: lv_xstring    TYPE xstring,
        lo_excel      TYPE REF TO cl_fdt_xl_spreadsheet,
        lv_docname    TYPE string,
        lt_worksheets TYPE STANDARD TABLE OF string,
        lv_worksheet  TYPE string,
        lv_lines      TYPE i,
        lo_data       TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data_bin>  TYPE STANDARD TABLE,
                 <ls_data_bin>  TYPE any,
                 <lv_value_bin> TYPE any,
                 <lv_value>     TYPE any.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = gv_bin_len
    IMPORTING
      buffer       = lv_xstring
    TABLES
      binary_tab   = gt_raw
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  CREATE OBJECT lo_excel
    EXPORTING
      document_name = lv_docname
      xdocument     = lv_xstring.

  IF lo_excel IS NOT INITIAL.
    lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING worksheet_names = lt_worksheets ).
  ENDIF.

  DESCRIBE TABLE lt_worksheets LINES lv_lines.

  IF lt_worksheets[] IS NOT INITIAL.
    READ TABLE lt_worksheets INTO lv_worksheet INDEX lv_lines.
    lo_data = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lv_worksheet ).
    ASSIGN lo_data->* TO <lt_data_bin>.
  ENDIF.

  IF <lt_data_bin> IS ASSIGNED.
    LOOP AT <lt_data_bin> ASSIGNING <ls_data_bin> FROM 2.
      CLEAR: wa_file.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data_bin> TO <lv_value_bin>.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT sy-index OF STRUCTURE wa_file TO <lv_value>.
          IF sy-subrc EQ 0.
            <lv_value> = <lv_value_bin>.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      IF wa_file IS NOT INITIAL.
        APPEND wa_file TO it_file.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATA_EX
*&---------------------------------------------------------------------*
FORM convert_data_ex.
  DATA: lv_xstring    TYPE xstring,
        lo_excel      TYPE REF TO cl_fdt_xl_spreadsheet,
        lv_docname    TYPE string,
        lt_worksheets TYPE STANDARD TABLE OF string,
        lv_worksheet  TYPE string,
        lv_lines      TYPE i,
        lo_data       TYPE REF TO data.

  FIELD-SYMBOLS: <lt_data_bin>  TYPE STANDARD TABLE,
                 <ls_data_bin>  TYPE any,
                 <lv_value_bin> TYPE any,
                 <lv_value>     TYPE any.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = gv_bin_len
    IMPORTING
      buffer       = lv_xstring
    TABLES
      binary_tab   = gt_raw
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  CREATE OBJECT lo_excel
    EXPORTING
      document_name = lv_docname
      xdocument     = lv_xstring.

  IF lo_excel IS NOT INITIAL.
    lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING worksheet_names = lt_worksheets ).
  ENDIF.

  DESCRIBE TABLE lt_worksheets LINES lv_lines.

  IF lt_worksheets[] IS NOT INITIAL.
    READ TABLE lt_worksheets INTO lv_worksheet INDEX lv_lines.
    lo_data = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lv_worksheet ).
    ASSIGN lo_data->* TO <lt_data_bin>.
  ENDIF.

  IF <lt_data_bin> IS ASSIGNED.
    LOOP AT <lt_data_bin> ASSIGNING <ls_data_bin> FROM 2.
      CLEAR: wa_file_extend.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data_bin> TO <lv_value_bin>.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT sy-index OF STRUCTURE wa_file_extend TO <lv_value>.
          IF sy-subrc EQ 0.
            <lv_value> = <lv_value_bin>.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      IF wa_file_extend IS NOT INITIAL.
        APPEND wa_file_extend TO it_file_extend.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_CREATE                                    *FSD30*
*&---------------------------------------------------------------------*
*& R4 : mandatory + duplicate (GST/PAN) checks for CREATE mode.       *
*& Invalid rows are logged (msgty 'E') and removed from it_file so     *
*& they are never processed; valid rows continue. Batch never stops.   *
*&---------------------------------------------------------------------*
FORM validate_create.                                       "*FSD30 R4
  DATA: lt_valid    TYPE STANDARD TABLE OF ty_file_bp,
        lt_seen_pan TYPE HASHED TABLE OF j_1ipanno WITH UNIQUE KEY table_line,
        lt_seen_gst TYPE HASHED TABLE OF stcd3     WITH UNIQUE KEY table_line,
        lv_row      TYPE i,
        lv_err      TYPE string.

  LOOP AT it_file INTO wa_file.
    lv_row = sy-tabix.
    CLEAR: lv_err, w_log.

    " mandatory fields
    IF wa_file-partn_grp  IS INITIAL. lv_err = |{ lv_err }BP Grouping missing; |.       ENDIF.
    IF wa_file-partn_cat  IS INITIAL. lv_err = |{ lv_err }Partner Category missing; |.  ENDIF.
    IF wa_file-name_first IS INITIAL. lv_err = |{ lv_err }Name1 missing; |.             ENDIF.

    " master-data existence for the extension targets
    IF wa_file-bukrs IS NOT INITIAL.
      SELECT SINGLE bukrs FROM t001 INTO @DATA(lv_bukrs) WHERE bukrs = @wa_file-bukrs.
      IF sy-subrc <> 0. lv_err = |{ lv_err }Company Code { wa_file-bukrs } does not exist; |. ENDIF.
    ENDIF.
    IF wa_file-ekorg IS NOT INITIAL.
      SELECT SINGLE ekorg FROM t024e INTO @DATA(lv_ekorg) WHERE ekorg = @wa_file-ekorg.
      IF sy-subrc <> 0. lv_err = |{ lv_err }Purch Org { wa_file-ekorg } does not exist; |. ENDIF.
    ENDIF.

    " duplicate check : within file + against database (O4 - confirm precedence)
    IF wa_file-stcd3 IS NOT INITIAL.
      IF line_exists( lt_seen_gst[ table_line = wa_file-stcd3 ] ).
        lv_err = |{ lv_err }Duplicate GST { wa_file-stcd3 } within file; |.
      ELSE.
        INSERT wa_file-stcd3 INTO TABLE lt_seen_gst.
        SELECT SINGLE partner FROM dfkkbptaxnum INTO @DATA(lv_ptnr) WHERE taxnum = @wa_file-stcd3.
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

    " verdict
    IF lv_err IS NOT INITIAL.
      w_log         = CORRESPONDING #( wa_file ).
      w_log-rowno   = lv_row.
      w_log-msgty   = 'E'.
      w_log-message = lv_err.
      APPEND w_log TO t_log.        " logged as failed, not processed
    ELSE.
      APPEND wa_file TO lt_valid.   " keep for processing
    ENDIF.
  ENDLOOP.

  it_file = lt_valid.               " only valid rows go forward
ENDFORM.                                                    "*FSD30 R4

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_CHANGE                                    *FSD30*
*&---------------------------------------------------------------------*
*& R3/R4 : BP number mandatory and must already exist. Bad rows logged *
*& and skipped; batch continues.                                       *
*&---------------------------------------------------------------------*
FORM validate_change.                                       "*FSD30 R3/R4
  DATA: lt_valid TYPE STANDARD TABLE OF ty_file_extend,
        lv_row   TYPE i,
        lv_err   TYPE string,
        lv_bp    TYPE bu_partner.

  LOOP AT it_file_extend INTO wa_file_extend.
    lv_row = sy-tabix.
    CLEAR lv_err.

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
ENDFORM.                                                    "*FSD30 R3/R4

*&---------------------------------------------------------------------*
*&      Form  CREATE_BP_VENDOR
*&---------------------------------------------------------------------*
FORM create_bp_vendor.
  DATA: lv_rowno TYPE i.                                    "*FSD30 R1

  it_file_all[] = it_file[].
* it_file_all[] = it_file[].                                "*FSD30 R2
* DELETE it_file WHERE bukrs IS INITIAL.  "<-- baseline removed: no
*   longer silently drop rows that carry no company code.
  LOOP AT it_file INTO wa_file.
    lv_rowno = sy-tabix.                                    "*FSD30 R1 (capture before any READ TABLE)
    CLEAR: businesspartnerextern, partnercategory, partnergroup,
           centraldata, centraldataperson, centraldataorganization, addressdata.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING input  = wa_file-bpartner
      IMPORTING output = wa_file-bpartner.

    partnercategory = wa_file-partn_cat.
    partnergroup    = wa_file-partn_grp.

    CLEAR businesspartnerextern.

    " Create General BP
    PERFORM fill_central_data_vendor.
    PERFORM fill_address_vendor.

    " Check if BP exists
    IF wa_file-bpartner IS NOT INITIAL.
      SELECT SINGLE partner FROM but000 INTO @DATA(lv_partner) WHERE partner = @wa_file-bpartner.
      IF sy-subrc <> 0.
        businesspartnerextern = wa_file-bpartner.
      ELSE.
        partner_change = abap_true.
      ENDIF.
    ENDIF.
    IF lv_partner IS INITIAL AND ( wa_file-bpartner IS INITIAL OR wa_file-bpartner IS NOT INITIAL ).
      PERFORM call_bapi_bupa_create.
    ELSE.
      PERFORM call_bapi_bupa_central_change.
    ENDIF.

    IF businesspartner IS NOT INITIAL.
      " Add Vendor Roles (FLVN00 for FI, FLVN01 for Purchasing)
      PERFORM add_vendor_roles.

      SELECT SINGLE link~vendor
        FROM but000 AS bp
        INNER JOIN cvi_vend_link AS link ON bp~partner_guid = link~partner_guid
        WHERE bp~partner = @wa_file-bpartner
        INTO @DATA(lv_vend_id).
      IF sy-subrc = 0.
        lv_vendor = lv_vend_id.
        w_log-message = |{ w_log-message }Linked Vendor: { lv_vend_id }.|.
        SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
        IF sy-subrc = 0.
          wa_file-lifnr = lfa1-lifnr.
        ENDIF.
        SELECT SINGLE * FROM but020 WHERE partner = wa_file-bpartner.
        REFRESH: t_lfa1[].
        SELECT lifnr ktokk FROM lfa1 INTO TABLE t_lfa1 WHERE lifnr = lv_vendor.

        CREATE OBJECT lo_data.
        CALL METHOD lo_data->create_vendor_data.
      ENDIF.
      SELECT SINGLE link~vendor
        FROM but000 AS bp
        INNER JOIN cvi_vend_link AS link ON bp~partner_guid = link~partner_guid
        WHERE bp~partner = @wa_file-bpartner
        INTO @lv_vend_id.
      IF lv_vend_id IS NOT INITIAL.
        IF partner_change IS INITIAL.
          UPDATE lfa1 SET ven_class = wa_file-ven_class
                          j_1ipanno = wa_file-j_1ipanno
                          j_1iexcd  = wa_file-j_1iexcd
                          j_1iexrn  = wa_file-j_1iexrn
                          j_1iexrg  = wa_file-j_1iexrg
                          j_1iexdi  = wa_file-j_1iexdi
                          j_1iexco  = wa_file-j_1iexco
                          j_1ivtyp  = wa_file-j_1ivtyp
                          j_1isern  = wa_file-j_1isern
                          j_1kftbus = wa_file-j_1kftbus
                          j_1kftind = wa_file-j_1kftind
                          bahns     = wa_file-bahns
                          stenr     = wa_file-stenr
                          profs     = wa_file-profs
            WHERE lifnr = lv_vendor.
          COMMIT WORK AND WAIT.
          w_log-message = |{ w_log-message }LFA1 data modified. |.
        ENDIF.
      ENDIF.
    ELSE.
      w_log-message = |{ w_log-message }Vendor Creation Failed. |.
    ENDIF.

    "--- FSD30 R1/R2 : classify the record status (S/W/E) + row number ---
    w_log-rowno = lv_rowno.
    IF businesspartner IS INITIAL.
      w_log-msgty = 'E'.                       " creation failed
    ELSE.
      w_log-stat_cc = COND #( WHEN wa_file-bukrs IS INITIAL THEN 'W' ELSE 'S' ).
      w_log-stat_po = COND #( WHEN wa_file-ekorg IS INITIAL THEN 'W' ELSE 'S' ).
      IF w_log-message CS 'Fail' OR w_log-message CS 'ERROR'
         OR w_log-stat_cc = 'W' OR w_log-stat_po = 'W'.
        w_log-msgty = 'W'.
      ELSE.
        w_log-msgty = 'S'.
      ENDIF.
    ENDIF.
    "--- end FSD30 R1/R2 ---

    APPEND w_log TO t_log.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
    CLEAR: lv_vend_id, businesspartner, wa_file, partner_change.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_CENTRAL_DATA_VENDOR
*&---------------------------------------------------------------------*
FORM fill_central_data_vendor.
  centraldata = VALUE #(
    searchterm1       = wa_file-searchterm1
    searchterm2       = wa_file-searchterm2
    title_key         = wa_file-title
    partnertype       = wa_file-partnertype
    partnerlanguage   = 'E'
    partnerlanguageiso = 'EN' ).

  centraldatax = CORRESPONDING #( centraldata ).

  centraldataperson = COND #( WHEN partnercategory = 1
    THEN VALUE #( firstname  = wa_file-name_first
                  lastname   = wa_file-name_last
                  birthname  = wa_file-name_last2
                  middlename = wa_file-name_middle
                  correspondlanguage    = 'E'
                  correspondlanguageiso = 'EN' ) ).

  centraldataorganization = COND #( WHEN partnercategory = 2
    THEN VALUE #( name1 = wa_file-name_first
                  name2 = wa_file-name_last
                  name3 = wa_file-name_last2
                  name4 = wa_file-name_middle ) ).

  centraldatagroup = COND #( WHEN partnercategory = 3
    THEN VALUE #( namegroup1 = wa_file-name_first
                  namegroup2 = wa_file-name_last ) ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_ADDRESS_VENDOR
*&---------------------------------------------------------------------*
FORM fill_address_vendor.
  CLEAR: it_maildata[], it_faxdata[], it_telephondata[].

  addressdata = VALUE #(
    street       = wa_file-street
    str_suppl1   = wa_file-str_suppl1
    str_suppl2   = wa_file-str_suppl2
    str_suppl3   = wa_file-str_suppl3
    location     = wa_file-location
    building     = wa_file-building
    room_no      = wa_file-roomnumber
    floor        = wa_file-floor
    district     = wa_file-district
    home_city    = wa_file-home_city
    postl_cod1   = wa_file-postl_cod1
    city         = wa_file-city
    country      = wa_file-country
    region       = wa_file-region
    langu        = 'E'
    languiso     = 'EN'
    time_zone    = wa_file-time_zone
    validfromdate = COND #( WHEN wa_file-valid_from IS NOT INITIAL
                            THEN |{ wa_file-valid_from+6(4) }{ wa_file-valid_from+3(2) }{ wa_file-valid_from+0(2) }| ELSE '' )
    validtodate   = COND #( WHEN wa_file-valid_to IS NOT INITIAL
                            THEN |{ wa_file-valid_to+6(4) }{ wa_file-valid_to+3(2) }{ wa_file-valid_to+0(2) }| ELSE '' ) ).

  " Telephone Data
  it_telephondata = VALUE #(
    ( country = wa_file-country telephone = wa_file-mob_number std_no = 'X' r_3_user = '3' consnumber = '001' home_flag = 'X' )
    ( country = wa_file-country telephone = wa_file-tel_number std_no = 'X' r_3_user = '1' consnumber = '002' home_flag = 'X' ) ).

  " If second phone exists
  IF wa_file-tel_number_3 IS NOT INITIAL.
    it_telephondata = VALUE #( BASE it_telephondata
      ( country = wa_file-country telephone = wa_file-tel_number_3 std_no = 'X' r_3_user = '1' consnumber = '003' home_flag = 'X' ) ).
  ENDIF.

  " Compact Email and Fax assignment
  it_faxdata  = VALUE #( ( fax = wa_file-fax ) ).
  it_maildata = VALUE #( ( e_mail = wa_file-smtp_addr std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '001' ) ).

  IF wa_file-email_1 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_1 std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '002' ) ).
  ENDIF.
  IF wa_file-email_2 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_2 std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '002' ) ).
  ENDIF.
  IF wa_file-email_3 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_3 std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '002' ) ).
  ENDIF.
  IF wa_file-email_4 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_4 std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '002' ) ).
  ENDIF.
  IF wa_file-email_5 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_5 std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '002' ) ).
  ENDIF.
  IF wa_file-email_6 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_6 std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '002' ) ).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_BUPA_CREATE
*&---------------------------------------------------------------------*
FORM call_bapi_bupa_create.
  CLEAR businesspartner.
  CALL FUNCTION 'BAPI_BUPA_CREATE_FROM_DATA'
    EXPORTING
      businesspartnerextern   = businesspartnerextern
      partnercategory         = partnercategory
      partnergroup            = partnergroup
      centraldata             = centraldata
      centraldataperson       = centraldataperson
      centraldataorganization = centraldataorganization
      centraldatagroup        = centraldatagroup
      addressdata             = addressdata
    IMPORTING
      businesspartner         = businesspartner
    TABLES
      telefondata             = it_telephondata
      faxdata                 = it_faxdata
      e_maildata              = it_maildata
      return                  = return.

  w_log = CORRESPONDING #( wa_file ).
  w_log-bpartner = COND #( WHEN businesspartnerextern IS NOT INITIAL THEN businesspartnerextern
                           WHEN businesspartner IS NOT INITIAL       THEN businesspartner
                           ELSE wa_file-bpartner ).
  IF businesspartner IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    WAIT UP TO 2 SECONDS.

    IF wa_file-stcd3 IS NOT INITIAL AND wa_file-taxtype IS NOT INITIAL.
      MODIFY dfkkbptaxnum FROM @( VALUE #(
        client   = sy-mandt
        partner  = w_log-bpartner
        taxtype  = wa_file-taxtype
        taxnum   = wa_file-stcd3
        taxnumxl = '' ) ).

      IF sy-subrc = 0.
        COMMIT WORK.
        w_log-message = 'BP VENDOR CREATED/UPDATED : TAX UPDATED'.
      ELSE.
        w_log-message = 'BP VENDOR CREATED/UPDATED : TAX TABLE MODIFY FAILED'.
      ENDIF.
    ELSE.
      w_log-message = 'BP VENDOR CREATED/UPDATED : TAX NUMBER MISSING IN FILE'.
    ENDIF.
  ENDIF.
  IF line_exists( return[ type = 'E' ] ).
    w_log-message = |{ w_log-message } / ERRORS: | &&
      REDUCE string( INIT m = ``
        FOR wa IN return WHERE ( type = 'E' )
        NEXT m = COND #( WHEN m = `` THEN wa-message ELSE |{ m };{ wa-message }| ) ).
  ENDIF.

  IF businesspartnerextern IS NOT INITIAL.
    businesspartner = businesspartnerextern.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ADD_VENDOR_ROLES
*&---------------------------------------------------------------------*
FORM add_vendor_roles.
  DATA: businesspartnerrole TYPE bapibus1006_bproles-partnerrole,
        lv_role_status      TYPE string.
  " FLVN00 : FI Vendor  (Company Code Data)
  " FLVN01 : Supplier   (Purchasing Data)

  REFRESH: return.

  LOOP AT VALUE char10_t( ( 'FLVN00' ) ( 'FLVN01' ) ) INTO DATA(lv_role).
    businesspartnerrole = lv_role.
    CALL FUNCTION 'BAPI_BUPA_ROLE_ADD_2'
      EXPORTING
        businesspartner     = businesspartner
        businesspartnerrole = businesspartnerrole
        validfromdate       = sy-datum
        validuntildate      = '99991231'
      TABLES
        return              = return.
    IF NOT line_exists( return[ type = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      lv_role_status = |{ lv_role_status }{ lv_role } Added. |.
    ELSE.
      lv_role_status = |{ lv_role_status }{ lv_role } Fail:{ return[ type = 'E' ]-message }. |.
    ENDIF.
    CLEAR: businesspartnerrole.
  ENDLOOP.

  w_log-message = |{ w_log-message }Roles:{ lv_role_status }|.

  IF wa_file-isec IS NOT INITIAL.
    industrysector          = wa_file-isec.
    industrysectorkeysystem = '0001'.
    defaultindustry         = ''.

    CALL FUNCTION 'BAPI_INDUSTRYSECTOR_ADD'
      EXPORTING
        businesspartner         = businesspartner
        industrysectorkeysystem = industrysectorkeysystem
        industrysector          = industrysector
        defaultindustry         = defaultindustry
      TABLES
        return                  = return.

    IF line_exists( return[ type = 'E' ] ) OR line_exists( return[ type = 'A' ] ).
      w_log-message = |{ w_log-message }Industry Add Failed: | &&
        REDUCE string( INIT m = ``
          FOR wa IN return WHERE ( type = 'E' OR type = 'A' )
          NEXT m = COND #( WHEN m = `` THEN wa-message ELSE |{ m };{ wa-message }| ) ).
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      w_log-message = |{ w_log-message }Industry Sector { industrysector } Added.|.
    ENDIF.
  ENDIF.

  REFRESH: return.

  IF wa_file-identificationcategory IS NOT INITIAL AND wa_file-identificationnumber IS NOT INITIAL.
    DATA: lv_id_from_date TYPE dats,
          lv_id_to_date   TYPE dats.

    " Convert Dates to Internal Format
    IF wa_file-id_from_date IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING date_external = wa_file-id_from_date
        IMPORTING date_internal = lv_id_from_date
        EXCEPTIONS OTHERS = 0.
    ENDIF.
    IF wa_file-id_to_date IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING date_external = wa_file-id_to_date
        IMPORTING date_internal = lv_id_to_date
        EXCEPTIONS OTHERS = 0.
    ENDIF.

    CALL FUNCTION 'BAPI_IDENTIFICATION_ADD'
      EXPORTING
        businesspartner        = businesspartner
        identificationcategory = CONV bu_id_category( wa_file-identificationcategory )
        identificationnumber   = CONV bu_id_number( wa_file-identificationnumber )
        identification         = VALUE bapibus1006_identification(
                                   identrydate     = sy-datum
                                   idvalidfromdate = lv_id_from_date
                                   idvalidtodate   = lv_id_to_date )
      TABLES
        return                 = return.

    " Log only Errors using REDUCE
    IF line_exists( return[ type = 'E' ] ) OR line_exists( return[ type = 'A' ] ).
      w_log-message = |{ w_log-message }ID { wa_file-identificationnumber } Error: | &&
        REDUCE string( INIT m = ``
          FOR wa IN return WHERE ( type = 'E' OR type = 'A' )
          NEXT m = COND #( WHEN m = `` THEN wa-message ELSE |{ m };{ wa-message }| ) ).
    ELSE.
      " Commit and Wait to finalize BP buffer synchronization
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      w_log-message = |{ w_log-message }ID { wa_file-identificationnumber } Added. |.
    ENDIF.

    CLEAR: lv_id_from_date, lv_id_to_date, return.
  ENDIF.

  iv_partner = |{ businesspartner ALPHA = IN }|.
  wa_file-bpartner = iv_partner.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_BANK_TO_BP
*&---------------------------------------------------------------------*
FORM upload_bank_to_bp.
  DATA: et_return   TYPE TABLE OF bapiret2,
        et_bank     TYPE STANDARD TABLE OF bapibus1006_bankdetails,
        et_return1  TYPE STANDARD TABLE OF bapiret2,
        ls_bnka_ret TYPE bapiret2,
        lv_bank_temp TYPE c LENGTH 10.

  CLEAR iv_partner.
  iv_partner = |{ wa_file-bpartner ALPHA = IN }|.

  " Handle Bank Master Data (bnka)
  SELECT SINGLE bankl FROM bnka INTO @DATA(lv_exists)
    WHERE banks = @wa_file-banks AND bankl = @wa_file-bankl.

  IF sy-subrc <> 0.
    " Use BAPI instead of direct INSERT BNKA
    CALL FUNCTION 'BAPI_BANK_CREATE'
      EXPORTING
        bank_ctry    = wa_file-banks
        bank_key     = wa_file-bankl
        bank_address = VALUE bapi1011_address(
                         bank_name   = wa_file-banka
                         swift_code  = wa_file-swift
                         region      = wa_file-region_1
                         street      = wa_file-street_1
                         city        = wa_file-city_1
                         bank_branch = wa_file-brnch )
      IMPORTING
        return       = ls_bnka_ret.
    IF ls_bnka_ret-type <> 'E'.
      COMMIT WORK AND WAIT.   " Ensure BNKA is available for the next step
      w_log-message = |{ w_log-message }BNKA Created.|.
    ELSE.
      w_log-message = |{ w_log-message }ERROR creating BNKA:{ ls_bnka_ret-message }|.
    ENDIF.
  ELSE.
    " Update existing Bank Master using standard SQL if details changed
    UPDATE bnka SET provz = @wa_file-region_1, stras = @wa_file-street_1,
                    ort01 = @wa_file-city_1, brnch = @wa_file-brnch,
                    banka = @wa_file-banka, swift = @wa_file-swift
      WHERE banks = @wa_file-banks AND bankl = @wa_file-bankl.
    COMMIT WORK AND WAIT.
    w_log-message = |{ w_log-message }BNKA Updated.|.
  ENDIF.

  DATA(lv_bank_id) = wa_file-bank_id.

  IF lv_bank_id IS INITIAL.
    CALL FUNCTION 'BUPA_BANKDETAILS_GET'
      EXPORTING
        iv_partner    = iv_partner
        iv_valid_date = sy-datlo
      TABLES
        et_bankdetails = et_bank
        et_return      = et_return1.

    lv_bank_temp = lines( et_bank ) + 1.
    lv_bank_id = |{ lv_bank_temp ALPHA = IN }|.
  ENDIF.

  CALL FUNCTION 'BUPA_BANKDETAIL_ADD'
    EXPORTING
      iv_partner   = iv_partner
      iv_bkvid     = CONV bu_bkvid( lv_bank_id )
      is_bankdetail = VALUE bapibus1006_bankdetail(
                        bank_ctry     = wa_file-banks
                        bank_key      = wa_file-bankl
                        bank_acct     = wa_file-bankn
                        accountholder = wa_file-koinh
                        bank_ref      = wa_file-bkref
                        ctrl_key      = wa_file-controlkey
                        bankaccountname = wa_file-ebpp_accname )
    TABLES
      et_return    = et_return.

  IF NOT line_exists( et_return[ type = 'E' ] ).
    COMMIT WORK AND WAIT.
    w_log-message = |{ w_log-message }Bank Details (ID:{ lv_bank_id }) Added/Updated.|.
  ELSE.
    w_log-message = |{ w_log-message }Bank Add Failed: | &&
      REDUCE string( INIT m = ``
        FOR wa IN et_return WHERE ( type = 'E' )
        NEXT m = COND #( WHEN m = `` THEN wa-message ELSE |{ m };{ wa-message }| ) ).
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXTEND_BP                                          *FSD30*
*&---------------------------------------------------------------------*
*& Shared maintain routine used by EXTEND (rb_ext) and CHANGE (rb_chg).*
*& Changes vs baseline:                                                *
*&  (a) NO hard stop - a missing/invalid BP is logged and the loop     *
*&      CONTINUEs (baseline did MESSAGE + LEAVE LIST-PROCESSING).      *
*&  (b) "already extended" detection on LFB1 (CC) and LFM1 (Purch) ->  *
*&      Warning, kept separate from creation status (R2).             *
*&  (c) CHANGE-safe : each datax flag is set ONLY when the file field  *
*&      is populated, so blank cells never overwrite master data (R3). *
*&  (d) per-role status stat_cc / stat_po + overall msgty S/W/E (R1).  *
*&---------------------------------------------------------------------*
FORM extend_bp.                                             "*FSD30 R2/R3
  DATA: lv_row     TYPE i,
        lv_mode_tx TYPE string.

  lv_mode_tx = COND #( WHEN rb_chg = 'X' THEN 'changed' ELSE 'extended' ).  "*FSD30 R3

  LOOP AT it_file_extend INTO wa_file_extend.
    lv_row = sy-tabix.
    CLEAR: w_log_ex, l_partner, lv_vendor, businesspartner.
    MOVE-CORRESPONDING wa_file_extend TO w_log_ex.
    w_log_ex-rowno = lv_row.                                "*FSD30 R1

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING input  = wa_file_extend-bpartner
      IMPORTING output = wa_file_extend-bpartner.

    SELECT SINGLE partner FROM but000 INTO l_partner
      WHERE partner = wa_file_extend-bpartner.
    IF sy-subrc <> 0.
      "*FSD30 (a) no hard stop - log and carry on
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
        REFRESH: t_lfa1[].
        SELECT lifnr ktokk FROM lfa1 INTO TABLE t_lfa1 WHERE lifnr = lv_vendor.
      ENDIF.
    ENDIF.

    ls_vendors-header-object_instance-lifnr = lv_vendor.
    ls_vendors-header-object_task           = 'U'.

    "================= COMPANY CODE VIEW =================
    IF wa_file_extend-bukrs IS NOT INITIAL.
      REFRESH: lt_company[].
      CLEAR ls_company.

      "*FSD30 (b) already-extended detection -> warning, separate status
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

      "*FSD30 (c) CHANGE-safe : fill data + datax ONLY for populated fields
      IF wa_file_extend-akont IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING input  = wa_file_extend-akont
          IMPORTING output = ls_company-data-akont.
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

      "*FSD30 (b) already-extended detection -> warning, separate status
      SELECT SINGLE ekorg FROM lfm1 INTO @DATA(lv_lfm1)
        WHERE lifnr = @lv_vendor AND ekorg = @wa_file_extend-ekorg.
      IF sy-subrc = 0.
        w_log_ex-stat_po = 'W'.
        w_log_ex-message = |{ w_log_ex-message }Purch Org { wa_file_extend-ekorg } already extended; |.
      ELSE.
        w_log_ex-stat_po = 'S'.
      ENDIF.

      ls_purchasing-task           = 'M'.
      ls_purchasing-data_key-ekorg = wa_file_extend-ekorg.   " PURCHASING ORGANIZATION

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
      " GR / Service-based IV kept as baseline defaults for the purchasing view
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
    " CALL THE METHOD FOR CREATION/EXTENSION OF VENDOR.
    CALL METHOD vmd_ei_api=>maintain_bapi
      EXPORTING
        is_master_data           = gs_vmds_extern
      IMPORTING
        es_master_data_correct   = gs_vmds_succ
        es_message_correct       = gs_succ_messages
        es_master_data_defective = gs_vmds_error
        es_message_defective     = gs_err_messages.

    IF gs_err_messages-is_error IS INITIAL.
      COMMIT WORK.
      WAIT UP TO 2 SECONDS.
      "*FSD30 overall status = worst of the per-role statuses
      w_log_ex-msgty   = COND #( WHEN w_log_ex-stat_cc = 'W' OR w_log_ex-stat_po = 'W' THEN 'W' ELSE 'S' ).
      w_log_ex-message = |{ w_log_ex-message }Vendor { lv_vendor } { lv_mode_tx } successfully.|.
      CLEAR w_msg.
    ELSE.
      ROLLBACK WORK.
      w_log_ex-msgty = 'E'.
      LOOP AT gs_err_messages-messages INTO DATA(ls_msg).
        IF w_log_ex-message IS INITIAL.
          w_log_ex-message = ls_msg-message.
        ELSE.
          w_log_ex-message = |{ w_log_ex-message } / { ls_msg-message }|.
        ENDIF.
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
ENDFORM.                                                    "*FSD30 R2/R3

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_ERROR_LOG_CR                              *FSD30*
*&---------------------------------------------------------------------*
*& R1 : error-only download for the CREATE log (msgty 'E'/'A').        *
*&---------------------------------------------------------------------*
FORM download_error_log_cr.                                 "*FSD30 R1
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
    EXPORTING
      default_extension = 'XLS'
      default_file_name = |BP_Vendor_ERROR_Log_{ sy-datum }_{ sy-uzeit }.xls|
    CHANGING
      filename = lv_filename
      path     = lv_path
      fullpath = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
        confirm_overwrite     = 'X'
      TABLES
        data_tab              = lt_err
      EXCEPTIONS
        file_write_error = 1
        OTHERS           = 2.
    IF sy-subrc = 0.
      MESSAGE 'Error log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                                                    "*FSD30 R1

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_ERROR_LOG_EX                              *FSD30*
*&---------------------------------------------------------------------*
*& R1 : error-only download for the EXTEND / CHANGE log.               *
*&---------------------------------------------------------------------*
FORM download_error_log_ex.                                 "*FSD30 R1
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
    EXPORTING
      default_extension = 'XLS'
      default_file_name = |BP_Vendor_Ext_ERROR_Log_{ sy-datum }_{ sy-uzeit }.xls|
    CHANGING
      filename = lv_filename
      path     = lv_path
      fullpath = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
        confirm_overwrite     = 'X'
      TABLES
        data_tab              = lt_err
      EXCEPTIONS
        file_write_error = 1
        OTHERS           = 2.
    IF sy-subrc = 0.
      MESSAGE 'Error log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                                                    "*FSD30 R1

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_LOG_TO_EXCEL   (baseline full-log; retained)
*&---------------------------------------------------------------------*
FORM download_log_to_excel.
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'XLSX'
      default_file_name = |BP_Vendor_Log_{ sy-datum }_{ sy-uzeit }.xls|
    CHANGING
      filename = lv_filename
      path     = lv_path
      fullpath = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
        confirm_overwrite     = 'X'
      TABLES
        data_tab              = t_log
      EXCEPTIONS
        file_write_error = 1
        OTHERS           = 2.
    IF sy-subrc = 0.
      MESSAGE 'Log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG                                        *FSD30*
*&---------------------------------------------------------------------*
FORM display_log.
  " Inline Field Catalog Definition
  "*FSD30 R1 : columns per FSD - Row No, BP, Supplier Name, Status,
  "            CC/PO ext. status, GST, PAN, Message.
  DATA(lt_fcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'ROWNO'      seltext_m = 'Row No.' )
    ( fieldname = 'BPARTNER'   seltext_m = 'BP Number'     hotspot = 'X' )
    ( fieldname = 'NAME_FIRST' seltext_m = 'Supplier Name' )
    ( fieldname = 'MSGTY'      seltext_m = 'Status' )
    ( fieldname = 'STAT_CC'    seltext_m = 'CC Ext.' )
    ( fieldname = 'STAT_PO'    seltext_m = 'PO Ext.' )
    ( fieldname = 'STCD3'      seltext_m = 'GST No.' )
    ( fieldname = 'J_1IPANNO'  seltext_m = 'PAN No.' )
    ( fieldname = 'MESSAGE'    seltext_m = 'Message'  outputlen = 255 ) ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    colwidth_optimize = 'X'
    zebra             = 'X' ).

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = ls_layout
      it_fieldcat             = lt_fcat
    TABLES
      t_outtab                = t_log
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_LOG_TO_EXCEL_EX   (baseline full-log; retained)
*&---------------------------------------------------------------------*
FORM download_log_to_excel_ex.
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'XLSX'
      default_file_name = |BP_Vendor__Extension_Log_{ sy-datum }_{ sy-uzeit }.xls|
    CHANGING
      filename = lv_filename
      path     = lv_path
      fullpath = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
        confirm_overwrite     = 'X'
      TABLES
        data_tab              = t_log_ex
      EXCEPTIONS
        file_write_error = 1
        OTHERS           = 2.
    IF sy-subrc = 0.
      MESSAGE 'Log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG_EX                                     *FSD30*
*&---------------------------------------------------------------------*
FORM display_log_ex.
  " Inline Field Catalog Definition
  "*FSD30 R1 : add Row No + separate CC/PO status columns.
  DATA(lt_fcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'ROWNO'    seltext_m = 'Row No.' )
    ( fieldname = 'BPARTNER' seltext_m = 'Vendor Code'          hotspot = 'X' )
    ( fieldname = 'BUKRS'    seltext_m = 'Company Code' )
    ( fieldname = 'EKORG'    seltext_m = 'Purchase Organization' )
    ( fieldname = 'MSGTY'    seltext_m = 'Status' )
    ( fieldname = 'STAT_CC'  seltext_m = 'CC Ext.' )
    ( fieldname = 'STAT_PO'  seltext_m = 'PO Ext.' )
    ( fieldname = 'MESSAGE'  seltext_m = 'Log Details'  outputlen = 255 ) ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    colwidth_optimize = 'X'
    zebra             = 'X' ).

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE_EX'
      is_layout               = ls_layout
      it_fieldcat             = lt_fcat
    TABLES
      t_outtab                = t_log_ex
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&IC1'.       " Standard Hotspot / Double-click code
      IF rs_selfield-fieldname = 'BPARTNER' AND rs_selfield-value IS NOT INITIAL.
        " 1. Create a navigation request
        DATA(lo_request) = NEW cl_bupa_navigation_request( ).
        lo_request->set_partner_number( |{ rs_selfield-value ALPHA = IN }| ). " Ensure leading zeros
        lo_request->set_bupa_activity( '03' ).   " 03 = Display, 02 = Change

        " 2. Set UI options (optional: hide the locator/history sidebar)
        DATA(lo_options) = NEW cl_bupa_dialog_joel_options( ).
        lo_options->set_locator_visible( abap_false ).

        " 3. Start the BP transaction with this specific navigation
        cl_bupa_dialog_joel=>start_with_navigation(
          EXPORTING
            iv_request              = lo_request
            iv_options              = lo_options
            iv_in_new_internal_mode = abap_true ).   " Opens in the same window
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.
  DATA: lt_header TYPE slis_t_listheader,
        lv_total  TYPE i,
        lv_errors TYPE i.

  " Calculate stats for the header
  lv_total  = lines( t_log ).
  lv_errors = REDUCE i( INIT count = 0 FOR m IN t_log WHERE ( msgty CA 'EA' ) NEXT count = count + 1 ).

  " 1. Main Title (Type H)
  APPEND VALUE #( typ = 'H' info = 'BP Vendor Upload Execution Log' ) TO lt_header.

  " 2. Selection Info (Type S)
  APPEND VALUE #( typ = 'S' key = 'Date:' info = |{ sy-datum DATE = USER }| ) TO lt_header.
  APPEND VALUE #( typ = 'S' key = 'User:' info = |{ sy-uname }| )             TO lt_header.

  " 3. Summary Action (Type A)
  APPEND VALUE #( typ = 'A' info = |Total Records: { lv_total }| )  TO lt_header.
  APPEND VALUE #( typ = 'A' info = |Errors Found: { lv_errors }| )  TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE_EX
*&---------------------------------------------------------------------*
FORM top_of_page_ex.
  DATA: lt_header TYPE slis_t_listheader,
        lv_total  TYPE i,
        lv_errors TYPE i.

  " Calculate stats for the header
  lv_total  = lines( t_log_ex ).
  lv_errors = REDUCE i( INIT count = 0 FOR m IN t_log_ex WHERE ( msgty CA 'EA' ) NEXT count = count + 1 ).

  " 1. Main Title (Type H)
  APPEND VALUE #( typ = 'H' info = 'BP Vendor Extension Upload Execution Log' ) TO lt_header.

  " 2. Selection Info (Type S)
  APPEND VALUE #( typ = 'S' key = 'Date:' info = |{ sy-datum DATE = USER }| ) TO lt_header.
  APPEND VALUE #( typ = 'S' key = 'User:' info = |{ sy-uname }| )             TO lt_header.

  " 3. Summary Action (Type A)
  APPEND VALUE #( typ = 'A' info = |Total Records: { lv_total }| )  TO lt_header.
  APPEND VALUE #( typ = 'A' info = |Errors Found: { lv_errors }| )  TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_BUPA_CENTRAL_CHANGE
*&---------------------------------------------------------------------*
FORM call_bapi_bupa_central_change.
  CLEAR businesspartner.
  DATA: tax_return TYPE bapiret2_t.
  x_save_add-save_addr = 'X'.
  businesspartner = wa_file-bpartner.

  " Map data based on Partner Category using modern VALUE and SWITCH expressions
  CASE partnercategory.
    WHEN 1.
      centraldatapersonx = VALUE #( firstname            = abap_true
                                    lastname             = abap_true
                                    birthname            = abap_true
                                    correspondlanguage   = abap_true
                                    correspondlanguageiso = abap_true ).
      chk_address = VALUE #( BASE chk_address langu = 'E' languiso = 'EN' ).
    WHEN 2.
      centraldataorganizationx = VALUE #( name1    = abap_true
                                          name2    = abap_true
                                          name3    = abap_true
                                          name4    = abap_true
                                          loc_no_1 = abap_true
                                          loc_no_2 = abap_true ).
    WHEN 3.
      central_groupx = VALUE #( namegroup1 = 'X'
                                namegroup2 = 'X' ).
  ENDCASE.

  CALL FUNCTION 'BAPI_BUPA_CENTRAL_CHANGE'
    EXPORTING
      businesspartner           = wa_file-bpartner
      centraldataperson         = centraldataperson
      centraldataorganization   = centraldataorganization
      centraldatagroup          = central_group
      centraldataperson_x       = centraldatapersonx
      centraldataorganization_x = centraldataorganizationx
      centraldatagroup_x        = central_groupx
      duplicate_check_address   = chk_address
    TABLES
      return                    = return.

  w_log = CORRESPONDING #( wa_file ).

  IF businesspartner IS NOT INITIAL.
    " Synchronous commit - wait='X' makes 'WAIT UP TO' unnecessary
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.

    w_log-message = COND #( WHEN line_exists( return[ type = 'E' ] )
                            THEN 'BUSINESS PARTNER IS NOT CHANGED'
                            ELSE 'BUSINESS PARTNER CHANGED' ).

    IF line_exists( return[ type = 'E' ] ).
      w_log-message = return[ type = 'E' ]-message.
    ENDIF.

    w_log-bpartner = COND #( WHEN businesspartnerextern IS NOT INITIAL
                             THEN businesspartnerextern
                             ELSE businesspartner ).
  ENDIF.

  " Final global variable update
  businesspartner = COND #( WHEN businesspartnerextern IS NOT INITIAL
                            THEN businesspartnerextern
                            ELSE businesspartner ).
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHANGE_BP_VENDOR   (RETIRED - not called)         *FSD30*
*&---------------------------------------------------------------------*
*& Superseded by the change-aware EXTEND_BP (blank-safe M-update) plus *
*& VALIDATE_CHANGE. Retained here, unused, for reference/rollback only.*
*& The CHANGE mode is now wired in START-OF-SELECTION to EXTEND_BP.    *
*&---------------------------------------------------------------------*
FORM change_bp_vendor.
  LOOP AT it_file_extend ASSIGNING FIELD-SYMBOL(<fs_change>).
    CLEAR: businesspartnerextern, partnercategory, partnergroup,
           centraldata, centraldataperson, centraldataorganization, addressdata.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING input  = <fs_change>-bpartner
      IMPORTING output = <fs_change>-bpartner.

    CLEAR businesspartnerextern.

    IF wa_file-bpartner IS NOT INITIAL.
      SELECT SINGLE partner FROM but000 INTO @DATA(lv_partner) WHERE partner = @<fs_change>-bpartner.
      IF sy-subrc <> 0.
        businesspartnerextern = <fs_change>-bpartner.
      ENDIF.
    ENDIF.
    IF lv_partner IS NOT INITIAL AND <fs_change>-bpartner IS NOT INITIAL.
      PERFORM call_bapi_bupa_central_change.
    ENDIF.

    IF businesspartner IS NOT INITIAL.
      PERFORM add_vendor_roles.

      SELECT SINGLE link~vendor
        FROM but000 AS bp
        INNER JOIN cvi_vend_link AS link ON bp~partner_guid = link~partner_guid
        WHERE bp~partner = @wa_file-bpartner
        INTO @DATA(lv_vend_id).
      IF sy-subrc = 0.
        lv_vendor = lv_vend_id.
        w_log-message = |{ w_log-message }Linked Vendor: { lv_vend_id }.|.
        SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
        IF sy-subrc = 0.
          wa_file-lifnr = lfa1-lifnr.
        ENDIF.
        SELECT SINGLE * FROM but020 WHERE partner = wa_file-bpartner.
        REFRESH: t_lfa1[].
        SELECT lifnr ktokk FROM lfa1 INTO TABLE t_lfa1 WHERE lifnr = lv_vendor.

        CREATE OBJECT lo_data.
        CALL METHOD lo_data->create_vendor_data.
      ENDIF.
      SELECT SINGLE link~vendor
        FROM but000 AS bp
        INNER JOIN cvi_vend_link AS link ON bp~partner_guid = link~partner_guid
        WHERE bp~partner = @wa_file-bpartner
        INTO @lv_vend_id.
      IF lv_vend_id IS NOT INITIAL.
        UPDATE lfa1 SET ven_class = wa_file-ven_class
                        j_1ipanno = wa_file-j_1ipanno
                        j_1iexcd  = wa_file-j_1iexcd
                        j_1iexrn  = wa_file-j_1iexrn
                        j_1iexrg  = wa_file-j_1iexrg
                        j_1iexdi  = wa_file-j_1iexdi
                        j_1iexco  = wa_file-j_1iexco
                        j_1ivtyp  = wa_file-j_1ivtyp
                        j_1isern  = wa_file-j_1isern
                        j_1kftbus = wa_file-j_1kftbus
                        j_1kftind = wa_file-j_1kftind
                        bahns     = wa_file-bahns
                        stenr     = wa_file-stenr
                        profs     = wa_file-profs
          WHERE lifnr = lv_vendor.
        COMMIT WORK AND WAIT.
        w_log-message = |{ w_log-message }LFA1 data modified. |.
      ENDIF.
    ENDIF.
    APPEND w_log TO t_log.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
    CLEAR: lv_vend_id, businesspartner, wa_file.
  ENDLOOP.
ENDFORM.
