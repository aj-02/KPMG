*&---------------------------------------------------------------------*
*& Include          ZMM_VEND_MASTER_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&                      TABLES DECLARATION
*&---------------------------------------------------------------------*
TABLES: but000,lfa1,but020.

*&---------------------------------------------------------------------*
*&                      TYPES DECLARATION
*&---------------------------------------------------------------------*
"++ begin of changes for new template by Hemang Joshi
TYPES: BEGIN OF ty_file_bp,
         bpartner               TYPE bu_partner,        "1  Business Partner Number
         partn_cat              TYPE bu_type,           "2  Partner Type (2=Org,1=Person)
         partn_grp              TYPE bu_group,          "3  BP Grouping
         title                  TYPE ad_titletx,        "4  Title
         name_first             TYPE bu_nameor1,        "5  Name 1
         name_last              TYPE bu_nameor2,        "6  Name 2
         name_last2             TYPE bu_nameor3,        "7  Name 3
         name_middle            TYPE bu_nameor4,        "8  Name 4
         zz_bu_old              TYPE char20,            "9  NEW: Old Vendor Code (adjust length if you have a domain)
         searchterm1            TYPE bu_sort1,          "10 Search Term1
         searchterm2            TYPE bu_sort2,          "11 Search Term2
         building               TYPE ad_bldng,          "12 BUILDING
         roomnumber             TYPE ad_roomnum,        "13 ROOMNUMBER
         floor                  TYPE ad_floor,          "14 FLOOR
         street                 TYPE ad_street,         "15 STREET
         str_suppl1             TYPE ad_strspp1,        "16 STREET1
         str_suppl2             TYPE ad_strspp2,        "17 STREET2
         str_suppl3             TYPE ad_strspp3,        "18 STREET3
         location               TYPE ad_lctn,           "19 LOCATION
         district               TYPE ad_city2,          "20 DISTRICT
         home_city              TYPE ad_city3,          "21 HOME CITY
         postl_cod1             TYPE ad_pstcd1,         "22 Postal Code
         city                   TYPE ad_city1,          "23 City
         country                TYPE land1,             "24 Country
         region                 TYPE regio,             "25 Region (General)
         tel_number             TYPE ad_tlnmbr,         "26 Telephone number
         mob_number             TYPE ad_tlnmbr,         "27 Mobile number
*  bpkind      TYPE bu_bpkind,      "28 NEW: BP Kind      "removed Note: sequence changed
         fax                    TYPE ad_fxnmbr,         "29 Fax Number
         smtp_addr              TYPE ad_smtpadr,        "30 Email 0
         valid_from             TYPE string,            "31 Valid From (string; converted later)
         valid_to               TYPE string,            "32 Valid To (string; converted later)
         partnertype            TYPE bu_bpkind,         "33 Partner Type (free text from file)
         identificationcategory TYPE string,            "34 Identification Category
         identificationnumber   TYPE string,            "35 Identification Number
         id_from_date           TYPE string,            "36 ID From Date (string; converted later)
         id_to_date             TYPE string,            "37 ID To Date (string; converted later)
         tel_number_3           TYPE char10,            "38 Telephone no. 3
         email_1                TYPE ad_smtpadr,        "39 Email 1
         email_2                TYPE ad_smtpadr,        "40 Email 2
         email_3                TYPE ad_smtpadr,        "41 Email 3
         email_4                TYPE ad_smtpadr,        "42 Email 4
         email_5                TYPE ad_smtpadr,        "42 Email 4
         email_6                TYPE ad_smtpadr,        "42 Email 4
         j_1iexcd               TYPE j_1iexcd,          "43 J1I Excise - Dep#
         j_1iexrn               TYPE j_1iexrn,          "44 J1I Excise - Range
         j_1iexrg               TYPE j_1iexrg,          "45 J1I Excise - Division
         j_1iexdi               TYPE j_1iexdi,          "46 J1I Excise - District
         j_1iexco               TYPE j_1iexco,          "47 J1I Excise - Commissionerate
         j_1ivtyp               TYPE j_1ivtyp,          "48 J1I Vendor Type
         kunnr                  TYPE kna1-kunnr,        "49 Customer Number (moved from old #9)
         j_1ipanno              TYPE j_1ipanno,         "50 PAN
         j_1isern               TYPE j_1isern,          "51 Service TaxRegistration
         taxtype                TYPE dfkkbptaxnum-taxtype, "52 BP Tax Number Category
         stcd3                  TYPE stcd3,             "53 GST No.
         ven_class              TYPE char10,            "54 Vendor Class
         isec                   TYPE bus_bupa_industry_sectors-isec, "55 Industry Sector
         time_zone              TYPE char10,            "56 Time Zone

         " Company Code 57..65
         bukrs                  TYPE lfb1-bukrs,        "57 Company Code
         akont                  TYPE akont,             "58 Recon Account
         zuawa                  TYPE dzuawa,            "59 Sort Key
         altkn                  TYPE lfb1-altkn,        "60 Previous Account Number
         mindk                  TYPE mindk,             "61 Minority Indicator
         cerdt                  TYPE string,            "62 Certification Date (string; converted later)  "char10 --> string
         zterm                  TYPE dzterm,            "63 Payment Terms
         reprf                  TYPE reprf,             "64 Double Invoice Check
         kverm                  TYPE kverm,             "65 Account Memo / Check Flag

         " Payment (House Bank ID) 66
         hbkid                  TYPE hbkid,             "66 NEW: House Bank ID

         " Purchasing 67..87
         ekorg                  TYPE ekorg,             "67 Purchasing Organization
         waers                  TYPE waers,             "68 Currency
         zterm_org              TYPE dzterm,            "69 Payment Terms (Purchasing)
         verkf                  TYPE verkf,             "70 ResponsibleSalesperson
         inco1                  TYPE inco1,             "71 Incoterms Part 1
         inco1_l                TYPE inco2_l,           "72 Incoterms Location 1
         inco2                  TYPE inco2,             "73 Incoterms Part 2
         inco2_l                TYPE inco3_l,           "74 Incoterms Location 2
         webre                  TYPE webre,             "75 GR-based IV
         lebre                  TYPE lebre,             "76 Service-based IV
         kzaut                  TYPE kzaut,             "77 Automatic PO Allowed
         lfabc                  TYPE lfabc,             "78 ABC Indicator
         stenr                  TYPE stenr,             "79 TAN Number
         profs                  TYPE profs,             "80 MSME Number
         j_1kftind              TYPE indtyp,            "81 Type of Industry
         j_1kftbus              TYPE gestyp,            "82 Type of Business
         bahns                  TYPE bahns,             "83 Train Station (CIN)
         telf1                  TYPE telf1,             "84 Supplier Telephone No.
         ekgrp                  TYPE ekgrp,             "85 Purchasing Group
         kalsk                  TYPE kalsk,             "86 Schema Group
         parvw                  TYPE parvw,             "87 NEW: Partner Function (Purchasing override)

         " Payment / Bank 88..100
         banks                  TYPE banks,             "88 Bank Country/Region Key
         bank_id                TYPE bu_bkvid,          "89 BP Bank ID
         bankl                  TYPE bankl,             "90 Bank Key
         bankn                  TYPE bankn,             "91 Bank Account Number
         bkref                  TYPE bkref,             "92 Remaining Bank Account No.
         koinh                  TYPE koinh_fi,          "93 Account Holder Name
         ebpp_accname           TYPE ebpp_accname,      "94 User-defined Bank Account Name
         banka                  TYPE banka,             "95 Name of Financial Institution
         region_1               TYPE regio,             "96 Bank Region(second REGIO)
         street_1               TYPE bnka-stras,        "97 Bank Street
         city_1                 TYPE ort01,             "98 Bank City
         brnch                  TYPE brnch,             "99 Branch
         swift                  TYPE bnka-swift,        "100 Swift Code

         " Other / Log / Keys 101..103
         reason                 TYPE char100,           "101 Reason
         lifnr                  TYPE lifnr,             "102 Vendor Number
         flag                   TYPE c,                 "103 Flag

         " Withholding 104..114
         srno                   TYPE char4,             "104 WHT SRNO (group key)
         witht                  TYPE witht,             "105 Withholding Tax Type
         wt_subjct              TYPE wt_subjct,         "106 Subject toWHT?
         qsrec                  TYPE wt_qsrec,          "107 Type of Recipient
         wt_wtstcd              TYPE wt_wtstcd,         "108 WHT Identification Number
         wt_withcd              TYPE wt_withcd,         "109 WHT Code
         wt_exnr                TYPE wt_exnr,           "110 Exemption Certificate Number
         wt_exrt                TYPE wt_exrt,           "111 Exemption Rate
         wt_exdf                TYPE string,            "112 Exemption From Date
         wt_exdt                TYPE string,            "113 Exemption To Date
         wt_wtexrs              TYPE wt_wtexrs,         "114 Reason forExemption
         paymethod              TYPE lfb1-zwels,        "115 Payment Method
         controlkey             TYPE lfbk-bkont,        "116 Control Key
       END OF ty_file_bp.
TYPES: BEGIN OF ty_log.
         INCLUDE TYPE ty_file_bp.
TYPES:   msgty   TYPE bapi_mtype,
         message TYPE string,
*BOC By Arnav on 22/07/26
         rowno   TYPE i,          "FSD30 R1 row number in file
         stat_cc TYPE bapi_mtype, "FSD30 R2 Company Code ext status
         stat_po TYPE bapi_mtype, "FSD30 R2 Purch Org  ext status
*EOC By Arnav on 22/07/26
       END OF ty_log.
"-- end of changes for new template by Hemang Joshi


TYPES : BEGIN OF ty_file_extend,
          bpartner TYPE  bu_partner,
***COMPANY CODE DATA
          bukrs    TYPE lfb1-bukrs,
          akont    TYPE akont, "RECON ACCOUNT
          zuawa    TYPE dzuawa, "SORT KEY
          mindk    TYPE mindk,
          cerdt    TYPE char10, "CERDT,
          zterm    TYPE dzterm,
          reprf    TYPE reprf,
***PRCHASE ORAGANISATION****
          ekorg    TYPE ekorg,
          waers    TYPE waers,
          verkf    TYPE verkf,
          telf1    TYPE telf1,
          ekgrp    TYPE ekgrp,
          kalsk    TYPE kalsk,
        END OF ty_file_extend.

TYPES: BEGIN OF ty_file_vendor,
         lifnr TYPE lifnr,
       END OF ty_file_vendor.

TYPES: BEGIN OF ty_lfa1,
         lifnr TYPE lfa1-lifnr,
         ktokk TYPE lfa1-ktokk,
       END OF ty_lfa1.

TYPES: BEGIN OF ty_upload,
         client   TYPE mandt, " CLNT  3 0 CLIENT
         partner  TYPE bu_partner , "CHAR  10  0 BUSINESS PARTNER NUMBER
         taxtype  TYPE bptaxtype,  "CHAR 4 0 TAX NUMBER CATEGORY
         taxnum   TYPE bptaxnum , "CHAR  20  0 BUSINESS PARTNER TAX NUMBER
         taxnumxl TYPE bptaxnumxl, "  CHAR  60  0 BUSINESS PARTNER TAX NUMBER
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
*BOC By Arnav on 22/07/26
         rowno   TYPE i,          "FSD30 R1
         stat_cc TYPE bapi_mtype, "FSD30 R2
         stat_po TYPE bapi_mtype, "FSD30 R2
*EOC By Arnav on 22/07/26
       END OF ty_log_ex.
*&---------------------------------------------------------------------*
*&                INTERNAL TABLE & WORK AREA DECLARATION
*&---------------------------------------------------------------------*
DATA: gt_raw     TYPE solix_tab,
      gv_bin_len TYPE i.
DATA: it_file        TYPE TABLE OF ty_file_bp,
      it_file_all    TYPE TABLE OF ty_file_bp,
      wa_file        TYPE ty_file_bp,
      t_error        TYPE TABLE OF ty_file_bp,
      t_log          TYPE TABLE OF ty_log, "TY_LOG,
      w_log          TYPE ty_log, "TY_LOG.
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
      " Added by kedar Subrat On 25.09.2019 for extend CC data & Pur. Org. Data
      it_file_extend TYPE STANDARD TABLE OF ty_file_extend,
      wa_file_extend TYPE ty_file_extend.
" Ended by kedar Subrat On 25.09.2019 for extend CC data & Pur. Org. Data
*&---------------------------------------------------------------------*
*&                LOCAL AND GLOBAL VAIABLE DECLARATION
*&---------------------------------------------------------------------*
DATA : lv_flag,
       lv_vendor TYPE lfa1-lifnr,
       lv_length TYPE i.                    "Yashveer 19.10.2019
*       LE_DATA  TYPE REF TO LCL_DATA_1.
*&---------------------------------------------------------------------*
*&           LOCAL AND GLOBAL VAIABLE FOR ID NUMBER DECLARATION
*&---------------------------------------------------------------------*
DATA : lv_id_from_date            TYPE string, "BU_ID_VALID_DATE_FROM,
       lv_id_to_date              TYPE string, "BU_ID_VALID_DATE_TO,
       lv1_id_from_date           TYPE string,
       lv2_id_from_date           TYPE string,
       lv1_id_to_date             TYPE string,
       lv2_id_to_date             TYPE string,
       lv1_identificationcategory TYPE bapibus1006_identification_key-identificationcategory,
       lv2_identificationcategory TYPE string,
       lv1_identificationnumber   TYPE bapibus1006_identification_key-identificationnumber,
       lv2_identificationnumber   TYPE string.
*&---------------------------------------------------------------------*
*&                BP RELATED DATA DECLARATION
*&---------------------------------------------------------------------*
DATA: iv_partner                  TYPE bu_partner,
      wa_but000                   TYPE but000,
      wa_lfa1                     TYPE lfa1,
      partner_change              TYPE flag,
      businesspartnerextern       TYPE bapibus1006_head-bpartner,
      partnercategory             TYPE bapibus1006_head-partn_cat,
      partnergroup                TYPE bapibus1006_head-partn_grp,
      centraldata                 TYPE bapibus1006_central,
      centraldatax                TYPE bapibus1006_central_x,
      central_group               TYPE bapibus1006_central_group,
      central_groupx              TYPE bapibus1006_central_group_x,
      centraldataperson           TYPE bapibus1006_central_person,
      centraldatapersonx          TYPE bapibus1006_central_person_x,
      centraldataorganization     TYPE bapibus1006_central_organ,
      centraldataorganizationx    TYPE bapibus1006_central_organ_x,
      centraldatagroup            TYPE bapibus1006_central_group,
      addressdata                 TYPE bapibus1006_address,
      industries                  TYPE bapibus1006_industrysector,
      businesspartner             TYPE bapibus1006_head-bpartner,
      it_telephondata             TYPE STANDARD TABLE OF bapiadtel,
      wa_telephondata             TYPE bapiadtel,
      it_maildata                 TYPE STANDARD TABLE OF bapiadsmtp,
      wa_maildata                 TYPE bapiadsmtp,
      industrysector              LIKE bapibus1006_industrysector-industrysector,
      identification              LIKE bapibus1006_identification,
      defaultindustry             LIKE bapibus1006_industrysector-defaultindustrysector,
      defaultindustry_x           LIKE bapibus1006_industrysector_x,
      industrysectorkeysystem     LIKE bapibus1006_industrysector-industrysectorkeysystem,
      industrysectordetail        TYPE STANDARD TABLE OF bapibus1006_industrysector,
      l_partner                   TYPE bapibus1006_head-bpartner,
      it_faxdata                  TYPE STANDARD TABLE OF bapiadfax,
      wa_faxdata                  TYPE bapiadfax,
      return                      TYPE STANDARD TABLE OF bapiret2,
      x_save_add                  TYPE bapi4001_1,
      chk_address                 TYPE bapibus1006_address,
      businesspartnerrolecategory TYPE bapibus1006_bproles-partnerrolecategory,
      all_businesspartnerroles    TYPE bapibus1006_x-mark,
      businesspartnerrole         TYPE bapibus1006_bproles-partnerrole,
      differentiationtypevalue    TYPE bapibus1006_bproles-difftypevalue,
      validfromdate               TYPE bapibus1006_bprole_validity-bprolevalidfrom,
      validuntildate              TYPE bapibus1006_bprole_validity-bprolevalidto.
*&---------------------------------------------------------------------*
*&           Company Code Extend Related  DATA DECLARATION
*&---------------------------------------------------------------------*
DATA: lt_vendors               TYPE vmds_ei_extern_t,
      ls_vendors               TYPE vmds_ei_extern,
      ls_central               TYPE vmds_ei_vmd_central,
      lt_company               TYPE vmds_ei_company_t,
      ls_company               TYPE vmds_ei_company,
      ls_company_data          TYPE vmds_ei_vmd_company,
      is_master_data           TYPE vmds_ei_main,
      ls_address               TYPE cvis_ei_address1,
      es_master_data_correct   TYPE vmds_ei_main,
      es_message_correct       TYPE cvis_message,
      es_master_data_defective TYPE vmds_ei_main,
      es_message_defective     TYPE cvis_message.
*&---------------------------------------------------------------------*
*&           Purchasing Data Extend Related  DATA DECLARATION
*&---------------------------------------------------------------------*
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
*&---------------------------------------------------------------------*
*&                ALV RELATED DATA DECLARATION
*&---------------------------------------------------------------------*
DATA: t_fcat   TYPE slis_t_fieldcat_alv,
      w_fcat   TYPE slis_fieldcat_alv,
      s_layout TYPE slis_layout_alv.
