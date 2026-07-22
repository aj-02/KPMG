*&---------------------------------------------------------------------*
*& Include          ZMM_VEND_MASTER_FORMS
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
*BOC By Arnav on 22/07/26
    lv_header = |Business Partner Number{ lv_tab }Partner Type{ lv_tab }BP Grouping{ lv_tab }Title{ lv_tab }| &&
                |Name 1{ lv_tab }Name 2{ lv_tab }Name 3{ lv_tab }Name 4{ lv_tab }| &&
                |Old Vendor Code{ lv_tab }Search Term 1{ lv_tab }SearchTerm 2{ lv_tab }BUILDING{ lv_tab }| &&
                |ROOMNUMBER{ lv_tab }FLOOR{ lv_tab }STREET{ lv_tab }STREET1{ lv_tab }| &&
                |STREET2{ lv_tab }STREET3{ lv_tab }LOCATION{ lv_tab }DISTRICT{ lv_tab }| &&
                |HOME CITY{ lv_tab }Postal Code{ lv_tab }City{ lv_tab }Country{ lv_tab }| &&
                |Region (General){ lv_tab }Telephone number{ lv_tab }Mobile number{ lv_tab }Fax Number{ lv_tab }| &&
                |Email 0{ lv_tab }Valid From{ lv_tab }Valid To{ lv_tab }Partner Type{ lv_tab }| &&
                |Identification Category{ lv_tab }Identification Number{ lv_tab }ID From Date{ lv_tab }ID To Date{ lv_tab }| &&
                |Telephone no. 3{ lv_tab }Email 1{ lv_tab }Email 2{ lv_tab }Email 3{ lv_tab }| &&
                |Email 4{ lv_tab }Email 5{ lv_tab }Email 6{ lv_tab }J1IExcise - Dep{ lv_tab }J1I Excise - Range{ lv_tab }J1I Excise - Division{ lv_tab }| &&
                |J1I Excise - District{ lv_tab }J1I Excise - Commissionerate{ lv_tab }J1I Vendor Type{ lv_tab }Customer Number{ lv_tab }| &&
                |PAN{ lv_tab }Service Tax Registration{ lv_tab }BP Tax Number Category{ lv_tab }GST No.{ lv_tab }| &&
                |Vendor Class{ lv_tab }Industry Sector{ lv_tab }Time Zone{ lv_tab }Company Code{ lv_tab }| &&
                |Recon Account{ lv_tab }Sort Key{ lv_tab }Previous Account Number{ lv_tab }Minority Indicator{ lv_tab }| &&
                |Certification Date{ lv_tab }Payment Terms{ lv_tab }Double Invoice Check{ lv_tab }Account Memo / Check Flag{ lv_tab }| &&
                |NEW: House Bank ID{ lv_tab }Purchasing Organization{ lv_tab }Currency{ lv_tab }Payment Terms (Purchasing){ lv_tab }| &&
                |Responsible Salesperson{ lv_tab }Incoterms Part 1{ lv_tab }Incoterms Location 1{ lv_tab }Incoterms Part 2{ lv_tab }| &&
                |Incoterms Location 2{ lv_tab }GR-based IV{ lv_tab }Service-based IV{ lv_tab }Automatic PO Allowed{ lv_tab }| &&
                |ABC Indicator{ lv_tab }TAN Number{ lv_tab }MSME Number{ lv_tab }Type of Industry{ lv_tab }| &&
                |Type of Business{ lv_tab }Train Station (CIN){ lv_tab }Supplier Telephone No.{ lv_tab }Purchasing Group{ lv_tab }| &&
                |Schema Group{ lv_tab }Partner Function (Purchasing override){ lv_tab }Bank Country/Region Key{ lv_tab }BP Bank ID{ lv_tab }| &&
                |Bank Key{ lv_tab }Bank Account Number{ lv_tab }Remaining Bank Account No.{ lv_tab }Account Holder Name{ lv_tab }| &&
                |User-defined Bank Account Name{ lv_tab }Name of Financial Institution{ lv_tab }Bank Region{ lv_tab }Bank Street{ lv_tab }| &&
                |Bank City{ lv_tab }Branch{ lv_tab }Swift Code{ lv_tab }Reason{ lv_tab }| &&
                |Vendor Number{ lv_tab }Flag{ lv_tab }WHT SRNO (group key){ lv_tab }Withholding Tax Type{ lv_tab }| &&
                |Subject to WHT{ lv_tab }Type of Recipient{ lv_tab }WHTIdentification Number{ lv_tab }WHT Code{ lv_tab }| &&
                |Exemption Certificate Number{ lv_tab }Exemption Rate{ lv_tab }Exemption From Date{ lv_tab }Exemption To Date{ lv_tab }| &&
                |Reason for Exemption{ lv_tab }Payment Method{ lv_tab }Control Key|.
*EOC By Arnav on 22/07/26
  ELSEIF rb_ext = 'X' OR rb_chg = 'X'.
*BOC By Arnav on 22/07/26
    lv_header = |Business Partner Number{ lv_tab }Company Code{ lv_tab }Recon Account{ lv_tab }| &&
                |Sort Key{ lv_tab }Minority Indicator{ lv_tab }Certification Date{ lv_tab }| &&
                |Payment Terms{ lv_tab }Double Invoice Check{ lv_tab }Purchasing Org{ lv_tab }| &&
                |Currency{ lv_tab }Responsible Salesperson{ lv_tab }Vendor Tel{ lv_tab }| &&
                |Purchasing Group{ lv_tab }Schema Group| .
*EOC By Arnav on 22/07/26
  ENDIF.
  APPEND lv_header TO lt_file_data.


  " Open Save Dialog
  lv_filename = |BP_Vend_Template_{ sy-datum }_{ sy-uzeit }|.  "Changes by Arnav on 22/07/26

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
      write_field_separator = 'X' " Ensures Excel columns align
    TABLES
      data_tab              = lt_file_data.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALUE_REQUEST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM value_request.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name = sy-cprog
    IMPORTING
      file_name    = p_flname.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_EXCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_excel.
  DATA: lv_fname   TYPE string.

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
*& Form convert_data_cr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
      IMPORTING
        worksheet_names = lt_worksheets ).
  ENDIF.

  DESCRIBE TABLE lt_worksheets LINES lv_lines.

  IF lt_worksheets[] IS NOT INITIAL.
    READ TABLE lt_worksheets INTO lv_worksheet INDEX lv_lines.
    lo_data = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(lv_worksheet ).
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
*& Form convert_data_ex
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
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
      IMPORTING
        worksheet_names = lt_worksheets ).
  ENDIF.

  DESCRIBE TABLE lt_worksheets LINES lv_lines.

  IF lt_worksheets[] IS NOT INITIAL.
    READ TABLE lt_worksheets INTO lv_worksheet INDEX lv_lines.
    lo_data = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet(lv_worksheet ).
    ASSIGN lo_data->* TO <lt_data_bin>.
  ENDIF.

  IF <lt_data_bin> IS ASSIGNED.
    LOOP AT <lt_data_bin> ASSIGNING <ls_data_bin> FROM 2.
      CLEAR: wa_file_extend.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data_bin> TO <lv_value_bin>.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT sy-index OF STRUCTURE wa_file_extend TO <lv_value>.  "Changes by Arnav on 22/07/26
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
*& Form CREATE_BP_VENDOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_bp_vendor.
*  it_file_all[] = it_file[].
*  DELETE it_file WHERE bukrs IS INITIAL.

*     BASELINE (remove):
*         it_file_all[] = it_file[].
*         DELETE it_file WHERE bukrs IS INITIAL.
*     REPLACE WITH:
      it_file_all[] = it_file[].
*     Keep every valid row; a missing company code is handled as a
*     warning during logging (below), not a silent delete.
  LOOP AT it_file INTO wa_file.
    CLEAR : businesspartnerextern,
            partnercategory,
            partnergroup,
            centraldata,
            centraldataperson,
            centraldataorganization,
            addressdata.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_file-bpartner
      IMPORTING
        output = wa_file-bpartner.

    partnercategory = wa_file-partn_cat.
    partnergroup = wa_file-partn_grp.

    CLEAR businesspartnerextern.

    " Create General BP
    PERFORM fill_central_data_vendor.
    PERFORM fill_address_vendor.


*-- Begin of changes by Hemang for BP not getting created Req By: Om Prakash
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

*-- End of changes by Hemang for BP not getting created Req By: Om Prakash

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
        w_log-message = |{ w_log-message } Linked Vendor: { lv_vend_id }.|.  "Changes by Arnav on 22/07/26
        SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
        IF sy-subrc = 0.
          wa_file-lifnr = lfa1-lifnr.
        ENDIF.
        SELECT SINGLE * FROM but020 WHERE partner = wa_file-bpartner.
        REFRESH : t_lfa1[].
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
                      j_1kftbus = wa_file-j_1kftbus     " J Newly Added
                      j_1kftind = wa_file-j_1kftind     " J Newly Added
                      bahns     = wa_file-bahns         " J Newly Added
                      stenr     = wa_file-stenr         " J Newly Added
                      profs     = wa_file-profs
                         WHERE lifnr = lv_vendor.
          COMMIT WORK AND WAIT.
*BOC By Arnav on 22/07/26
          w_log-message = |{ w_log-message } LFA1 data modified. |.
        ENDIF.
      ENDIF.
*    ELSE.
*      w_log-message = |{ w_log-message } Vendor Creation Failed. |.
*    ENDIF.
*    APPEND w_log TO t_log.
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
*EOC By Arnav on 22/07/26
        ENDIF.
      ENDIF.
      APPEND w_log TO t_log.


    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
    CLEAR: lv_vend_id, businesspartner, wa_file, partner_change.
  ENDLOOP.
ENDFORM.
FORM fill_central_data_vendor.
  centraldata = VALUE #(
    searchterm1        = wa_file-searchterm1
    searchterm2        = wa_file-searchterm2
    title_key          = wa_file-title
    partnertype        = wa_file-partnertype
    partnerlanguage    = 'E'
    partnerlanguageiso = 'EN'
  ).

  centraldatax = CORRESPONDING #( centraldata ).

  centraldataperson = COND #( WHEN partnercategory = 1
                              THEN VALUE #( firstname = wa_file-name_first
                                            lastname  = wa_file-name_last
                                            birthname = wa_file-name_last2
                                            middlename = wa_file-name_middle
                                            correspondlanguage = 'E'
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
FORM fill_address_vendor.
  CLEAR: it_maildata[], it_faxdata[], it_telephondata[].

  addressdata = VALUE #(
    street      = wa_file-street
    str_suppl1  = wa_file-str_suppl1
    str_suppl2  = wa_file-str_suppl2
    str_suppl3  = wa_file-str_suppl3
    location    = wa_file-location
    building    = wa_file-building
    room_no     = wa_file-roomnumber
    floor       = wa_file-floor
    district    = wa_file-district
    home_city   = wa_file-home_city
    postl_cod1  = wa_file-postl_cod1
    city        = wa_file-city
    country     = wa_file-country
    region      = wa_file-region
    langu       = 'E'
    languiso    = 'EN'
    time_zone   = wa_file-time_zone
    validfromdate = COND #( WHEN wa_file-valid_from IS NOT INITIAL
                            THEN |{ wa_file-valid_from+6(4) }{ wa_file-valid_from+3(2) }{ wa_file-valid_from+0(2) }|  "Changes by Arnav on 22/07/26
                            ELSE '' )
    validtodate   = COND #( WHEN wa_file-valid_to IS NOT INITIAL
                            THEN |{ wa_file-valid_to+6(4) }{ wa_file-valid_to+3(2) }{ wa_file-valid_to+0(2) }|  "Changes by Arnav on 22/07/26
                            ELSE '' )
  ).

  " Telephone Data
  it_telephondata = VALUE #(
    ( country = wa_file-country telephone = wa_file-mob_number std_no ='X' r_3_user = '3' consnumber = '001' home_flag = 'X' )
    ( country = wa_file-country telephone = wa_file-tel_number std_no ='X' r_3_user = '1' consnumber = '002' home_flag = 'X' )
  ).

  " If second phone exists
  IF wa_file-tel_number_3 IS NOT INITIAL.
    it_telephondata = VALUE #( BASE it_telephondata
      ( country = wa_file-country telephone = wa_file-tel_number_3 std_no = 'X' r_3_user = '1' consnumber = '003' home_flag = 'X' )
    ).
  ENDIF.

  " Compact Email and Fax assignment
  it_faxdata  = VALUE #( ( fax = wa_file-fax ) ).
  it_maildata = VALUE #( ( e_mail = wa_file-smtp_addr std_no = 'X' std_recip = 'X' home_flag = 'X' consnumber = '001' ) ).

  IF wa_file-email_1 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_1 std_no = 'X' std_recip = 'X' home_flag= 'X' consnumber = '002' )
    ).
  ENDIF.
  IF wa_file-email_2 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_2 std_no = 'X' std_recip = 'X' home_flag= 'X' consnumber = '002' )
    ).
  ENDIF.
  IF wa_file-email_3 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_3 std_no = 'X' std_recip = 'X' home_flag= 'X' consnumber = '002' )
    ).
  ENDIF.
  IF wa_file-email_4 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_4 std_no = 'X' std_recip = 'X' home_flag= 'X' consnumber = '002' )
    ).
  ENDIF.
  IF wa_file-email_5 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_5 std_no = 'X' std_recip = 'X' home_flag= 'X' consnumber = '002' )
    ).
  ENDIF.
  IF wa_file-email_6 IS NOT INITIAL.
    it_maildata = VALUE #( BASE it_maildata
      ( e_mail = wa_file-email_6 std_no = 'X' std_recip = 'X' home_flag= 'X' consnumber = '002' )
    ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_BAPI_BUPA_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_bapi_bupa_create .

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
****      addressnotes            = it_addressnotes
      return                  = return.

  w_log = CORRESPONDING #( wa_file ).
  w_log-bpartner = COND #( WHEN businesspartnerextern IS NOT INITIAL THEN businesspartnerextern
                           WHEN businesspartner IS NOT INITIAL THEN businesspartner
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
          taxnumxl = ''
      ) ).

      IF sy-subrc = 0.
        COMMIT WORK.
        w_log-message = 'BP VENDOR CREATED/UPDATED: TAX UPDATED'.
      ELSE.
        w_log-message = 'BP VENDOR CREATED/UPDATED: TAX TABLE MODIFY FAILED'.
      ENDIF.
    ELSE.
      w_log-message = 'BP VENDOR CREATED/UPDATED: TAX NUMBER MISSING INFILE'.
    ENDIF.
  ENDIF.
  IF line_exists( return[ type = 'E' ] ).
    w_log-message = |{ w_log-message } / ERRORS: | &&  "Changes by Arnav on 22/07/26
                    REDUCE string( INIT m = ``
                        FOR wa IN return WHERE ( type = 'E' )
                        NEXT m = COND #( WHEN m = `` THEN wa-message
                                         ELSE |{ m }; { wa-message }| )).  "Changes by Arnav on 22/07/26
  ENDIF.

  IF businesspartnerextern IS NOT INITIAL.
    businesspartner =  businesspartnerextern.
  ENDIF.
ENDFORM.
FORM add_vendor_roles.
  DATA: businesspartnerrole TYPE bapibus1006_bproles-partnerrole,
        lv_role_status      TYPE string.
  " FLVN00: FI Vendor (Company Code Data)
  " FLVN01: Supplier (Purchasing Data)

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
*BOC By Arnav on 22/07/26
      lv_role_status = |{ lv_role_status }{ lv_role } Added. |.
    ELSE.
      lv_role_status = |{ lv_role_status }{ lv_role } Fail: { return[ type = 'E' ]-message }. |.
*EOC By Arnav on 22/07/26
    ENDIF.
    CLEAR: businesspartnerrole.
  ENDLOOP.

  w_log-message = |{ w_log-message } Roles: { lv_role_status }|.  "Changes by Arnav on 22/07/26
  IF wa_file-isec IS NOT INITIAL.
    industrysector = wa_file-isec.
    industrysectorkeysystem = '0001'.
    defaultindustry = ''.

    CALL FUNCTION 'BAPI_INDUSTRYSECTOR_ADD'
      EXPORTING
        businesspartner         = businesspartner
        industrysectorkeysystem = industrysectorkeysystem
        industrysector          = industrysector
        defaultindustry         = defaultindustry
      TABLES
        return                  = return.

    IF line_exists( return[ type = 'E' ] ) OR line_exists( return[ type= 'A' ] ).
      w_log-message = |{ w_log-message } Industry Add Failed: | &&  "Changes by Arnav on 22/07/26
                    REDUCE string( INIT m = ``
                        FOR wa IN return WHERE ( type = 'E' OR type = 'A' )
                        NEXT m = COND #( WHEN m = `` THEN wa-message
                                         ELSE |{ m }; { wa-message }| )).  "Changes by Arnav on 22/07/26
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      w_log-message = |{ w_log-message } Industry Sector { industrysector } Added.|.  "Changes by Arnav on 22/07/26
    ENDIF.
  ENDIF.

  REFRESH: return.

  IF wa_file-identificationcategory IS NOT INITIAL AND wa_file-identificationnumber IS NOT INITIAL.
    DATA: lv_id_from_date TYPE dats,
          lv_id_to_date   TYPE dats.

    " Convert Dates to Internal Format
    IF wa_file-id_from_date IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external = wa_file-id_from_date
        IMPORTING
          date_internal = lv_id_from_date
        EXCEPTIONS
          OTHERS        = 0.
    ENDIF.

    IF wa_file-id_to_date IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
        EXPORTING
          date_external = wa_file-id_to_date
        IMPORTING
          date_internal = lv_id_to_date
        EXCEPTIONS
          OTHERS        = 0.
    ENDIF.

    CALL FUNCTION 'BAPI_IDENTIFICATION_ADD'
      EXPORTING
        businesspartner        = businesspartner
        identificationcategory = CONV bu_id_category( wa_file-identificationcategory )
        identificationnumber   = CONV bu_id_number( wa_file-identificationnumber )
        identification         = VALUE bapibus1006_identification(
                                   identrydate      = sy-datum
                                   idvalidfromdate  = lv_id_from_date
                                   idvalidtodate    = lv_id_to_date )
      TABLES
        return                 = return.

    " Log only Errors using REDUCE
    IF line_exists( return[ type = 'E' ] ) OR line_exists( return[ type= 'A' ] ).
      w_log-message = |{ w_log-message } ID { wa_file-identificationnumber } Error: | &&  "Changes by Arnav on 22/07/26
                      REDUCE string( INIT m = ``
                          FOR wa IN return WHERE ( type = 'E' OR type ='A' )
                          NEXT m = COND #( WHEN m = `` THEN wa-message
                                           ELSE |{ m }; { wa-message }|) ).  "Changes by Arnav on 22/07/26
    ELSE.
      " Commit and Wait to finalize BP buffer synchronization
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
      w_log-message = |{ w_log-message } ID { wa_file-identificationnumber } Added. |.  "Changes by Arnav on 22/07/26
    ENDIF.

    CLEAR: lv_id_from_date, lv_id_to_date, return.
  ENDIF.

  iv_partner = |{ businesspartner ALPHA = IN }|.  "Changes by Arnav on 22/07/26
  wa_file-bpartner = iv_partner.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPLOAD_BANK_TO_BP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_bank_to_bp .
  DATA: et_return    TYPE TABLE OF bapiret2,
        et_bank      TYPE STANDARD TABLE OF bapibus1006_bankdetails,
        et_return1   TYPE STANDARD TABLE OF bapiret2,
        ls_bnka_ret  TYPE bapiret2,
        lv_bank_temp TYPE c LENGTH 10.

  CLEAR iv_partner.

  iv_partner = |{ wa_file-bpartner ALPHA = IN }|.  "Changes by Arnav on 22/07/26

  " Handle Bank Master Data (bnka)
  SELECT SINGLE bankl FROM bnka INTO @DATA(lv_exists)
    WHERE banks = @wa_file-banks AND bankl = @wa_file-bankl.

  IF sy-subrc <> 0.
    " Use BAPI instead of direct INSERT BNKA
    CALL FUNCTION 'BAPI_BANK_CREATE'
      EXPORTING
        bank_ctry    = wa_file-banks                    "++field name changes by Hemang Req By: Om Prakash on 25/02/2026
        bank_key     = wa_file-bankl
        bank_address = VALUE  bapi1011_address(
                        bank_name   = wa_file-banka
                        swift_code  = wa_file-swift
                        region      = wa_file-region_1
                        street      = wa_file-street_1
                        city        = wa_file-city_1
                        bank_branch = wa_file-brnch )
      IMPORTING
        return       = ls_bnka_ret.
    IF ls_bnka_ret-type <> 'E'.
      COMMIT WORK AND WAIT. " Ensure BNKA is available for the next step
*BOC By Arnav on 22/07/26
      w_log-message = |{ w_log-message } BNKA Created.|.
    ELSE.
      w_log-message = |{ w_log-message } ERROR creating BNKA: { ls_bnka_ret-message }|.
*EOC By Arnav on 22/07/26
    ENDIF.
  ELSE.
    " Update existing Bank Master using standard SQL if details changed
    UPDATE bnka SET provz = @wa_file-region_1, stras = @wa_file-street_1,
                    ort01 = @wa_file-city_1, brnch = @wa_file-brnch,
                    banka = @wa_file-banka, swift = @wa_file-swift
    WHERE banks = @wa_file-banks AND bankl = @wa_file-bankl.

    COMMIT WORK AND WAIT.
    w_log-message = |{ w_log-message } BNKA Updated.|.  "Changes by Arnav on 22/07/26
  ENDIF.

  DATA(lv_bank_id) = wa_file-bank_id.

  IF lv_bank_id IS INITIAL.
    CALL FUNCTION 'BUPA_BANKDETAILS_GET'
      EXPORTING
        iv_partner     = iv_partner
        iv_valid_date  = sy-datlo
      TABLES
        et_bankdetails = et_bank
        et_return      = et_return1.

    lv_bank_temp = lines( et_bank ) + 1.
    lv_bank_id = |{ lv_bank_temp ALPHA = IN }|.  "Changes by Arnav on 22/07/26
  ENDIF.

  CALL FUNCTION 'BUPA_BANKDETAIL_ADD'
    EXPORTING
      iv_partner    = iv_partner
      iv_bkvid      = CONV bu_bkvid( lv_bank_id )
      is_bankdetail = VALUE bapibus1006_bankdetail(
                        bank_ctry = wa_file-banks
                        bank_key  = wa_file-bankl
                        bank_acct = wa_file-bankn
                        accountholder = wa_file-koinh
                        bank_ref  = wa_file-bkref
                        ctrl_key  = wa_file-controlkey
                        bankaccountname = wa_file-ebpp_accname )
    TABLES
      et_return     = et_return.

  IF NOT line_exists( et_return[ type = 'E' ] ).
    COMMIT WORK AND WAIT.
*BOC By Arnav on 22/07/26
    w_log-message = |{ w_log-message } Bank Details (ID: { lv_bank_id }) Added/Updated.|.
  ELSE.
    w_log-message = |{ w_log-message } Bank Add Failed: | &&
*EOC By Arnav on 22/07/26
                    REDUCE string( INIT m = ``
                        FOR wa IN et_return WHERE ( type = 'E' )
                        NEXT m = COND #( WHEN m = `` THEN wa-message
                                         ELSE |{ m }; { wa-message }| )).  "Changes by Arnav on 22/07/26
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form extend_bp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*FORM extend_bp .
*  LOOP AT it_file_extend INTO wa_file_extend.
*    CLEAR w_log_ex.
*    MOVE-CORRESPONDING wa_file_extend TO w_log_ex.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = wa_file_extend-bpartner
*      IMPORTING
*        output = wa_file_extend-bpartner.
*    SELECT SINGLE partner  FROM but000 INTO l_partner WHERE partner =wa_file_extend-bpartner.
*    IF sy-subrc = 0.
*      businesspartner = wa_file_extend-bpartner.
*      SELECT SINGLE * FROM but000 INTO wa_but000 WHERE partner = wa_file_extend-bpartner AND partner_guid NE ''.
*      IF sy-subrc = 0.
*        SELECT SINGLE vendor FROM cvi_vend_link INTO lv_vendor
*               WHERE partner_guid = wa_but000-partner_guid.
*        IF sy-subrc = 0.
*          SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
*          REFRESH : t_lfa1[].
*          SELECT lifnr ktokk FROM lfa1 INTO TABLE t_lfa1 WHERE lifnr =lv_vendor.
*        ENDIF.
*      ENDIF.
*
*      ls_vendors-header-object_instance-lifnr = lv_vendor.
*      ls_vendors-header-object_task = 'U'.
*
*      IF wa_file_extend-bukrs IS NOT INITIAL.
*        REFRESH: lt_company[].
*        CLEAR ls_company.
*        ls_company-task                    = 'M'.
*        ls_company-data_key-bukrs  = wa_file_extend-bukrs.
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*          EXPORTING
*            input  = wa_file_extend-akont
*          IMPORTING
*            output = ls_company-data-akont.
*        ls_company-data-zterm        = wa_file_extend-zterm.
*        ls_company-datax-akont       = 'X'.
*        ls_company-datax-zterm      = 'X'.
*        ls_company-data-zuawa = wa_file_extend-zuawa. " sort key
*        ls_company-datax-zuawa = 'X'.
*        ls_company-data-mindk = wa_file_extend-mindk.
*        ls_company-datax-mindk = 'X'.
*        ls_company-data-cerdt  = COND #( WHEN wa_file-cerdt IS NOT INITIAL THEN |{ wa_file-cerdt+6(4) }{ wa_file-cerdt+3(2) }{ wa_file-cerdt+0(2) }| ELSE '' ).
*        ls_company-datax-cerdt = 'X'.
*        ls_company-data-reprf = wa_file_extend-reprf.
*        ls_company-datax-reprf = 'X'.
*
*        APPEND ls_company TO ls_vendors-company_data-company.
*
*      ENDIF.
*
*      IF wa_file_extend-ekorg IS NOT INITIAL.
*        REFRESH: et_parvw[], lt_purchasing[].
*        CLEAR: ls_purchasing.
*        ls_purchasing-task                   = 'M'.
*        ls_purchasing-data_key-ekorg = wa_file_extend-ekorg.                   "PURCHASING ORGANIZATION
*        ls_purchasing-data-waers = wa_file_extend-waers.
*        ls_purchasing-datax-waers = 'X'.
*
*        ls_purchasing-data-zterm = wa_file_extend-zterm.
*        ls_purchasing-datax-zterm = 'X'.
*        " ADDED BY KEDAR SUBRAT ON 03/08/2018 FOR SALES PERSON AND TELEPHONE NUMBER UPDATE
*        ls_purchasing-data-verkf = wa_file_extend-verkf.
*        ls_purchasing-datax-verkf = 'X'.
*
*        ls_purchasing-data-telf1 = wa_file_extend-telf1.
*        ls_purchasing-datax-telf1 = 'X'.
*        " ENDED BY KEDAR SUBRAT ON 03/08/2018 FOR SALES PERSON AND TELEPHONE NUMBER UPDATE
*        ls_purchasing-data-ekgrp = wa_file_extend-ekgrp.
*        ls_purchasing-datax-ekgrp = 'X'.
*
*        ls_purchasing-data-kalsk         = wa_file_extend-kalsk.                            "SCHEMA GROUP, VENDOR
*        ls_purchasing-datax-kalsk       = 'X'.
*
*        ls_purchasing-data-lebre       = 'X' .        " SERVICE-BASED INVOICE VERIFICATION
*        ls_purchasing-datax-lebre      = 'X'.
*
*
*        ls_purchasing-data-webre       = 'X'."WA_FILE-WEBRE .        " GR BASED INVOICE VERIFICATION
*        ls_purchasing-datax-webre      = 'X'.
*
*        CALL METHOD vmd_ei_api_check=>get_mand_partner_functions
*          EXPORTING
*            iv_ktokk = lfa1-ktokk
*          IMPORTING
*            et_parvw = et_parvw.
*
*        LOOP AT et_parvw INTO DATA(wa_parvw).
*          SELECT SINGLE parvw FROM wyt3
*            INTO @DATA(lv_pf_exists)
*            WHERE lifnr = @lv_vendor
*              AND ekorg = @wa_file_extend-ekorg
*              AND parvw = @wa_parvw-parvw.
*
*          APPEND VALUE #(
*            task     = COND #( WHEN lv_pf_exists IS NOT INITIAL THEN 'M' ELSE 'I' )
*            data_key = VALUE #( parvw = wa_parvw-parvw )
*            data     = VALUE #( partner = lv_vendor )
*            datax    = VALUE #( partner = 'X' )
*          ) TO lt_purch_func.
*        ENDLOOP.
*
*        ls_purchasing-functions-functions =  lt_purch_func[].
*        APPEND ls_purchasing TO ls_vendors-purchasing_data-purchasing.
*      ENDIF.
*      APPEND ls_vendors TO gs_vmds_extern-vendors.
*
*      vmd_ei_api=>initialize( ).
**   CALL THE METHOD FOR CREATION OF VENDOR.
*      CALL METHOD vmd_ei_api=>maintain_bapi
*        EXPORTING
*          is_master_data           = gs_vmds_extern
*        IMPORTING
*          es_master_data_correct   = gs_vmds_succ
*          es_message_correct       = gs_succ_messages
*          es_master_data_defective = gs_vmds_error
*          es_message_defective     = gs_err_messages.
*      IF gs_err_messages-is_error IS INITIAL.
*        COMMIT WORK.
*        WAIT UP TO 2 SECONDS.
*        w_log_ex-msgty = 'S'.
*        w_log_ex-message = |Vendor { lv_vendor } extended successfully.|.
*        CLEAR w_msg.
*      ELSE.
*        ROLLBACK WORK.
*        w_log_ex-msgty = 'E'.
*        LOOP AT gs_err_messages-messages INTO DATA(ls_msg).
*          IF w_log_ex-message IS INITIAL.
*            w_log_ex-message = ls_msg-message.
*          ELSE.
*            w_log_ex-message = |{ w_log_ex-message } / { ls_msg-message }|.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*      APPEND w_log_ex TO t_log_ex.
*    ELSE.
*      MESSAGE : 'PLEASE PROVIDE EXISTING BP NO' TYPE 'I' DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
*    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
*    REFRESH: lt_purch_func[],
*           ls_vendors-company_data-company[],
*           ls_vendors-purchasing_data-purchasing[],
*           gs_vmds_extern-vendors[].
*    CLEAR: wa_file_extend, gs_vmds_extern, ls_vendors, lv_vendor, businesspartner.
*  ENDLOOP.
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_log_to_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_log_to_excel.
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'XLSX'
      default_file_name = |BP_Vendor_Log_{ sy-datum }_{ sy-uzeit }.xls|  "Changes by Arnav on 22/07/26
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X' " Makes it readable by Excel
        confirm_overwrite     = 'X'
      TABLES
        data_tab              = t_log
      EXCEPTIONS
        file_write_error      = 1
        OTHERS                = 2.

    IF sy-subrc = 0.
      MESSAGE 'Log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_log .
  " Inline Field Catalog Definition (Avoids long manually-built tables)
  DATA(lt_fcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'BPARTNER'     seltext_m = 'Vendor Code' hotspot = 'X' )
    ( fieldname = 'PARTN_GRP'    seltext_m = 'Vendor Account group' )
    ( fieldname = 'NAME_FIRST'   seltext_m = 'Name 1' )
    ( fieldname = 'NAME_LAST'    seltext_m = 'Name 2' )
    ( fieldname = 'STCD3'        seltext_m = 'GST Tax Number' )
    ( fieldname = 'J_1IPANNO'    seltext_m = 'Pan No' )
    ( fieldname = 'Flag'         seltext_m = 'Error Type' )
    ( fieldname = 'MESSAGE'       seltext_m = 'Log Details' outputlen =255 )
  ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    colwidth_optimize = 'X'
    zebra             = 'X'
  ).

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
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_log_to_excel_ex
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_log_to_excel_ex.
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      default_extension = 'XLSX'
      default_file_name = |BP_Vendor__Extension_Log_{ sy-datum }_{ sy-uzeit }.xls|  "Changes by Arnav on 22/07/26
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath ).

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = lv_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X' " Makes it readable by Excel
        confirm_overwrite     = 'X'
      TABLES
        data_tab              = t_log_ex
      EXCEPTIONS
        file_write_error      = 1
        OTHERS                = 2.

    IF sy-subrc = 0.
      MESSAGE 'Log downloaded successfully.' TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_log_ex
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_log_ex.
  " Inline Field Catalog Definition (Avoids long manually-built tables)
  DATA(lt_fcat) = VALUE slis_t_fieldcat_alv(
    ( fieldname = 'BPARTNER' seltext_m = 'Vendor Code' hotspot = 'X' )
    ( fieldname = 'BUKRS'    seltext_m = 'Company Code' )
    ( fieldname = 'EKORG'    seltext_m = 'Purchase Organization' )
    ( fieldname = 'MSGTY'    seltext_m = 'Status' icon = 'X' )
    ( fieldname = 'MESSAGE'  seltext_m = 'Log Details' outputlen = 255 )
  ).

  DATA(ls_layout) = VALUE slis_layout_alv(
    colwidth_optimize = 'X'
    zebra             = 'X'
  ).

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
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
" Optional: Add this to make the Material Number clickable
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN '&IC1'. " Standard Hotspot/Double-click code
****      IF rs_selfield-fieldname = 'BPARTNER' AND rs_selfield-value IS NOT INITIAL.
****        SET PARAMETER ID 'BPA' FIELD rs_selfield-value.
****        CALL TRANSACTION 'BP' AND SKIP FIRST SCREEN.
****      ENDIF.
      IF rs_selfield-fieldname = 'BPARTNER' AND rs_selfield-value IS NOT INITIAL.

        " 1. Create a navigation request
        DATA(lo_request) = NEW cl_bupa_navigation_request( ).
        "Changes by Arnav on 22/07/26
        lo_request->set_partner_number( |{ rs_selfield-value ALPHA = IN}| ). " Ensure leading zeros
        lo_request->set_bupa_activity( '03' ). " 03 = Display, 02 = Change

        " 2. Set UI options (optional: hide the locator/history sidebar)
        DATA(lo_options) = NEW cl_bupa_dialog_joel_options( ).
        lo_options->set_locator_visible( abap_false ).

        " 3. Start the BP transaction with this specific navigation
        cl_bupa_dialog_joel=>start_with_navigation(
          EXPORTING
            iv_request              = lo_request
            iv_options              = lo_options
            iv_in_new_internal_mode = abap_true " Opens in the same window
        ).
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM TOP_OF_PAGE
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
*BOC By Arnav on 22/07/26
  APPEND VALUE #( typ = 'S' key = 'Date: '   info = |{ sy-datum DATE = USER }| ) TO lt_header.
  APPEND VALUE #( typ = 'S' key = 'User: '   info = |{ sy-uname }| ) TOlt_header.

  " 3. Summary Action (Type A)
  APPEND VALUE #( typ = 'A' info = |Total Records: { lv_total } | ) TO lt_header.
  APPEND VALUE #( typ = 'A' info = |Errors Found: { lv_errors }| ) TO lt_header.
*EOC By Arnav on 22/07/26

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM TOP_OF_PAGE
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
*BOC By Arnav on 22/07/26
  APPEND VALUE #( typ = 'S' key = 'Date: '   info = |{ sy-datum DATE = USER }| ) TO lt_header.
  APPEND VALUE #( typ = 'S' key = 'User: '   info = |{ sy-uname }| ) TOlt_header.

  " 3. Summary Action (Type A)
  APPEND VALUE #( typ = 'A' info = |Total Records: { lv_total } | ) TO lt_header.
  APPEND VALUE #( typ = 'A' info = |Errors Found: { lv_errors }| ) TO lt_header.
*EOC By Arnav on 22/07/26

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.
FORM call_bapi_bupa_central_change.
  CLEAR businesspartner.
  DATA: tax_return TYPE bapiret2_t.
  x_save_add-save_addr = 'X'.
  businesspartner      = wa_file-bpartner.

  " Map data based on Partner Category using modern VALUE and SWITCH expressions
  CASE partnercategory.
    WHEN 1.
      centraldatapersonx = VALUE #( firstname            = abap_true
                                    lastname             = abap_true
                                    birthname            = abap_true
                                    correspondlanguage   = abap_true
                                    correspondlanguageiso = abap_true ).
      chk_address        = VALUE #( BASE chk_address langu = 'E' languiso = 'EN' ).
    WHEN 2.
      centraldataorganizationx = VALUE #( name1 = abap_true
                                          name2 = abap_true
                                          name3 = abap_true
                                          name4 = abap_true
                                          loc_no_1 = abap_true
                                          loc_no_2 = abap_true ).
    WHEN 3.
      central_groupx           = VALUE #( namegroup1 = 'X'
                                          namegroup2 = 'X' ).
  ENDCASE.

  CALL FUNCTION 'BAPI_BUPA_CENTRAL_CHANGE'
    EXPORTING
      businesspartner           = wa_file-bpartner
****      centraldata               = centraldata
      centraldataperson         = centraldataperson
      centraldataorganization   = centraldataorganization
      centraldatagroup          = central_group
****      centraldata_x             = centraldatax
      centraldataperson_x       = centraldatapersonx
      centraldataorganization_x = centraldataorganizationx
      centraldatagroup_x        = central_groupx
      duplicate_check_address   = chk_address
    TABLES
      return                    = return
*     ADDRESSDUPLICATES         =
    .
  w_log = CORRESPONDING #( wa_file ).

  IF businesspartner IS NOT INITIAL.
    " Synchronous commit - wait = 'X' makes 'WAIT UP TO' unnecessary
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.

    w_log-message = COND #( WHEN line_exists( return[ type = 'E' ] )
                            THEN 'BUSINESS PARTNER IS NOT CHANGED'
                            ELSE 'BUSINESS PARTNER CHANGED' ).

    " Handle Tax Update only if BP was successful
****    IF NOT line_exists( return[ type = 'E' ] ).
****      IF wa_file-stcd3 IS NOT INITIAL AND wa_file-taxtype IS NOT INITIAL.
****        wa_final_2-taxnum = wa_file-stcd3.
****        wa_final_2-taxtype =  wa_file-taxtype.
****
****        CALL FUNCTION 'BAPI_BUPA_TAX_ADD'
****          EXPORTING
****            businesspartner = w_log-bpartner
****            taxtype         = wa_final_2-taxtype
****            taxnumber       = wa_final_2-taxnum
****          TABLES
****            return          = tax_return.
****        IF sy-subrc = 0.
****          COMMIT WORK AND WAIT.
****          w_log-message = |{ w_log-message } & GST UPDATED|.
****        ELSE.
****          LOOP AT tax_return INTO DATA(ls_ret_gst).
****            w_log-message = |{ w_log-message } / GST: { ls_ret_gst-message }|.
****          ENDLOOP.
****        ENDIF.
****      ELSE.
****        w_log-message = 'BP CREATED/UPDATED: STCD3 GST MISSING IN FILE'.
****      ENDIF.
****    ENDIF.

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
*& Form CREATE_BP_VENDOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_bp_vendor.
  LOOP AT it_file_extend ASSIGNING FIELD-SYMBOL(<fs_change>).
    CLEAR : businesspartnerextern,
            partnercategory,
            partnergroup,
            centraldata,
            centraldataperson,
            centraldataorganization,
            addressdata.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <fs_change>-bpartner
      IMPORTING
        output = <fs_change>-bpartner.

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
      " Add Vendor Roles (FLVN00 for FI, FLVN01 for Purchasing)
      PERFORM add_vendor_roles.

      SELECT SINGLE link~vendor
        FROM but000 AS bp
        INNER JOIN cvi_vend_link AS link ON bp~partner_guid = link~partner_guid
        WHERE bp~partner = @wa_file-bpartner
        INTO @DATA(lv_vend_id).
      IF sy-subrc = 0.
        lv_vendor = lv_vend_id.
        w_log-message = |{ w_log-message } Linked Vendor: { lv_vend_id }.|.  "Changes by Arnav on 22/07/26
        SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
        IF sy-subrc = 0.
          wa_file-lifnr = lfa1-lifnr.
        ENDIF.
        SELECT SINGLE * FROM but020 WHERE partner = wa_file-bpartner.
        REFRESH : t_lfa1[].
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
                    j_1kftbus = wa_file-j_1kftbus     " J Newly Added
                    j_1kftind = wa_file-j_1kftind     " J Newly Added
                    bahns     = wa_file-bahns         " J Newly Added
                    stenr     = wa_file-stenr         " J Newly Added
                    profs     = wa_file-profs
                       WHERE lifnr = lv_vendor.
        COMMIT WORK AND WAIT.
        w_log-message = |{ w_log-message } LFA1 data modified. |.  "Changes by Arnav on 22/07/26
      ENDIF.
    ENDIF.
    APPEND w_log TO t_log.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
    CLEAR: lv_vend_id, businesspartner, wa_file.
  ENDLOOP.
ENDFORM.



*&=====================================================================*
*&  UNIT 3  -  NEW  -  Include ZMM_VEND_MASTER_FORMS                   *
*&  FSD30 R4 : validation + duplicate check for CREATE mode.           *
*&  Invalid rows are logged (msgty 'E') and removed from it_file so    *
*&  they are never processed; valid rows continue. Batch never stops.  *
*&=====================================================================*
*BOC By Arnav on 22/07/26
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
      SELECT SINGLE ekorg FROM t024e INTO @DATA(lv_ekorg) WHERE ekorg =@wa_file-ekorg.
      IF sy-subrc <> 0.
        lv_err = |{ lv_err }Purch Org { wa_file-ekorg } does not exist;|.
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
*EOC By Arnav on 22/07/26


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
*BOC By Arnav on 22/07/26
  DATA: lv_row     TYPE i,
        lv_mode_tx TYPE string.

  lv_mode_tx = COND #( WHEN rb_chg = 'X' THEN 'changed' ELSE 'extended'). "R3
*EOC By Arnav on 22/07/26

  LOOP AT it_file_extend INTO wa_file_extend.
*BOC By Arnav on 22/07/26
    lv_row = sy-tabix.
    CLEAR: w_log_ex, l_partner, lv_vendor, businesspartner.
*EOC By Arnav on 22/07/26
    MOVE-CORRESPONDING wa_file_extend TO w_log_ex.
    "Changes by Arnav on 22/07/26
    w_log_ex-rowno = lv_row.                                "R1

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING  input  = wa_file_extend-bpartner
      IMPORTING  output = wa_file_extend-bpartner.

    SELECT SINGLE partner FROM but000 INTO l_partner
           WHERE partner = wa_file_extend-bpartner.
    IF sy-subrc <> 0.
      " (a) no hard stop - log and carry on
      w_log_ex-msgty   = 'E'.
      w_log_ex-message = 'Please provide an existing BP number'.  "Changes by Arnav on 22/07/26
      APPEND w_log_ex TO t_log_ex.
      CONTINUE.  "Changes by Arnav on 22/07/26
    ENDIF.

    businesspartner = wa_file_extend-bpartner.
    SELECT SINGLE * FROM but000 INTO wa_but000
           WHERE partner = wa_file_extend-bpartner AND partner_guid NE ''.
    IF sy-subrc = 0.
      SELECT SINGLE vendor FROM cvi_vend_link INTO lv_vendor
             WHERE partner_guid = wa_but000-partner_guid.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM lfa1 WHERE lifnr = lv_vendor.
        REFRESH t_lfa1[].  "Changes by Arnav on 22/07/26
        SELECT lifnr ktokk FROM lfa1 INTO TABLE t_lfa1 WHERE lifnr = lv_vendor.
      ENDIF.
    ENDIF.

    ls_vendors-header-object_instance-lifnr = lv_vendor.
    ls_vendors-header-object_task           = 'U'.

    "================= COMPANY CODE VIEW =================
    IF wa_file_extend-bukrs IS NOT INITIAL.
      REFRESH lt_company[].  "Changes by Arnav on 22/07/26
      CLEAR ls_company.

      " (b) already-extended detection -> warning, separate status (R2)
*BOC By Arnav on 22/07/26
      SELECT SINGLE bukrs FROM lfb1 INTO @DATA(lv_lfb1)
             WHERE lifnr = @lv_vendor AND bukrs = @wa_file_extend-bukrs.
*EOC By Arnav on 22/07/26
      IF sy-subrc = 0.
*BOC By Arnav on 22/07/26
        w_log_ex-stat_cc = 'W'.
        w_log_ex-message = |{ w_log_ex-message }CC { wa_file_extend-bukrs } already extended; |.
      ELSE.
        w_log_ex-stat_cc = 'S'.
*EOC By Arnav on 22/07/26
      ENDIF.

      ls_company-task           = 'M'.
      ls_company-data_key-bukrs = wa_file_extend-bukrs.

      " (c) CHANGE-safe : fill data + set datax ONLY for populated fields
      IF wa_file_extend-akont IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING  input  = wa_file_extend-akont
          IMPORTING  output = ls_company-data-akont.
        ls_company-datax-akont = 'X'.
      ENDIF.
*BOC By Arnav on 22/07/26
      IF wa_file_extend-zterm IS NOT INITIAL.
        ls_company-data-zterm = wa_file_extend-zterm.  ls_company-datax-zterm = 'X'.
      ENDIF.
      IF wa_file_extend-zuawa IS NOT INITIAL.
*EOC By Arnav on 22/07/26
        ls_company-data-zuawa = wa_file_extend-zuawa.  ls_company-datax-zuawa = 'X'.
      ENDIF.
      IF wa_file_extend-mindk IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_company-data-mindk = wa_file_extend-mindk.  ls_company-datax-mindk = 'X'.
      ENDIF.
*BOC By Arnav on 22/07/26
      IF wa_file_extend-cerdt IS NOT INITIAL.
        ls_company-data-cerdt = |{ wa_file_extend-cerdt+6(4) }{ wa_file_extend-cerdt+3(2) }{ wa_file_extend-cerdt+0(2) }|.
*EOC By Arnav on 22/07/26
        ls_company-datax-cerdt = 'X'.
      ENDIF.
      IF wa_file_extend-reprf IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_company-data-reprf = wa_file_extend-reprf.  ls_company-datax-reprf = 'X'.
      ENDIF.

      APPEND ls_company TO ls_vendors-company_data-company.
    ENDIF.

    "================= PURCHASING VIEW =================
    IF wa_file_extend-ekorg IS NOT INITIAL.
*BOC By Arnav on 22/07/26
      REFRESH: et_parvw[], lt_purchasing[], lt_purch_func[].
      CLEAR ls_purchasing.

      " (b) already-extended detection -> warning, separate status (R2)
      SELECT SINGLE ekorg FROM lfm1 INTO @DATA(lv_lfm1)
             WHERE lifnr = @lv_vendor AND ekorg = @wa_file_extend-ekorg.
*EOC By Arnav on 22/07/26
      IF sy-subrc = 0.
*BOC By Arnav on 22/07/26
        w_log_ex-stat_po = 'W'.
        w_log_ex-message = |{ w_log_ex-message }Purch Org { wa_file_extend-ekorg } already extended; |.
      ELSE.
        w_log_ex-stat_po = 'S'.
*EOC By Arnav on 22/07/26
      ENDIF.

      ls_purchasing-task            = 'M'.
      ls_purchasing-data_key-ekorg  = wa_file_extend-ekorg.

      IF wa_file_extend-waers IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_purchasing-data-waers = wa_file_extend-waers.  ls_purchasing-datax-waers = 'X'.
      ENDIF.
      IF wa_file_extend-zterm IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_purchasing-data-zterm = wa_file_extend-zterm.  ls_purchasing-datax-zterm = 'X'.
      ENDIF.
      IF wa_file_extend-verkf IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_purchasing-data-verkf = wa_file_extend-verkf.  ls_purchasing-datax-verkf = 'X'.
      ENDIF.
      IF wa_file_extend-telf1 IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_purchasing-data-telf1 = wa_file_extend-telf1.  ls_purchasing-datax-telf1 = 'X'.
      ENDIF.
      IF wa_file_extend-ekgrp IS NOT INITIAL.  "Changes by Arnav on 22/07/26
        ls_purchasing-data-ekgrp = wa_file_extend-ekgrp.  ls_purchasing-datax-ekgrp = 'X'.
      ENDIF.
      IF wa_file_extend-kalsk IS NOT INITIAL.  "Changes by Arnav on 22/07/26
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
*BOC By Arnav on 22/07/26
      w_log_ex-msgty   = COND #( WHEN w_log_ex-stat_cc = 'W' OR w_log_ex-stat_po = 'W'
                                 THEN 'W' ELSE 'S' ).
      w_log_ex-message = |{ w_log_ex-message }Vendor { lv_vendor } { lv_mode_tx } successfully.|.
*EOC By Arnav on 22/07/26
    ELSE.
      ROLLBACK WORK.
      w_log_ex-msgty = 'E'.
      " extension failure is recorded WITHOUT clearing per-role S/W flags (R2)
      LOOP AT gs_err_messages-messages INTO DATA(ls_msg).
*BOC By Arnav on 22/07/26
        w_log_ex-message = COND #( WHEN w_log_ex-message IS INITIAL
                                   THEN ls_msg-message
                                   ELSE |{ w_log_ex-message } / { ls_msg-message }| ).
*EOC By Arnav on 22/07/26
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
*&  UNIT 8  -  NEW  -  Include ZMM_VEND_MASTER_FORMS                   *
*&  FSD30 R1 : error-only download for the CREATE log. Builds a subset *
*&  of failed records (msgty 'E'/'A') and downloads it. No-op with a   *
*&  message when there is nothing to download.                         *
*&=====================================================================*
*BOC By Arnav on 22/07/26
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
*EOC By Arnav on 22/07/26
