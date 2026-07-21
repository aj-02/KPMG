*&---------------------------------------------------------------------*
*& WRICEF      : 195_BRD_FS_ZMB5B_Report   (Astral / UDAY, MM-CO)
*& Object      : ZRM07MLBD  (copy of standard MB5B program RM07MLBD)
*& Transaction : ZMB5B
*& Routine     : f0400_create_fieldcat  -  COMPLETE form, with the
*&               195_BRD_FS change integrated in place.
*&---------------------------------------------------------------------*
*& This is the ONLY routine that changes for this WRICEF. Everything
*& else in ZRM07MLBD (and its includes ZRM07MLDD / ZRM07MLBD_FORM_01 /
*& ZRM07MLBD_FORM_02 / ZRM07MLBD_CUST_FIELDS) is a 1:1 copy of the
*& standard program - create that copy with the SE38/ADT copy function,
*& then replace this form's body with the version below.
*&
*& THE CHANGE (marked >>> ZMB5B 195_BRD_FS ... <<<):
*&   In the standard code the amount column (DMBTR) is built only for
*&   the "Valuated Stock" radio button (IF NOT bwbst IS INITIAL). The
*&   FS asks for the amount (MSEG-DMBTR, keyed by MBLNR/MJAHR) to be
*&   shown for the "Storage Loc./Batch Stock" radio button too. DMBTR
*&   is already selected from MSEG and already carried on the detail
*&   row, so the change is purely to add its field-catalog entry for
*&   the LGBST view via an ELSEIF branch. No other logic is required.
*&
*& NOTES on the copied-standard content below:
*&   - SAP enhancement-framework statements (ENHANCEMENT-POINT /
*&     ENHANCEMENT ... ENDENHANCEMENT for IS-OIL 'OIH_RM07MLBD') are
*&     kept as comments here because a hand-built copy cannot reference
*&     the original enhancement spots. When you copy the program inside
*&     SAP with the copy function these are carried automatically and
*&     you do NOT need this file's commented versions - you only apply
*&     the marked ZMB5B block. This file is the readable "full form"
*&     you asked for; the SE38 copy is the build vehicle.
*&   - German field comments from the standard are rendered in English.
*&---------------------------------------------------------------------*

FORM f0400_create_fieldcat.

  CLEAR g_s_fieldcat.

* storage location  (special stocks O, V, W need no storage location)
  IF sobkz = 'O' OR sobkz = 'V' OR sobkz = 'W'.
  ELSE.
    g_s_fieldcat-fieldname   = 'LGORT'.
    g_s_fieldcat-ref_tabname = 'MSEG'.
    g_s_fieldcat-sp_group    = 'O'.
    PERFORM f0410_fieldcat USING c_take c_out.
  ENDIF.

* movement type
  g_s_fieldcat-fieldname   = 'BWART'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_out.

* special stock indicator
  g_s_fieldcat-fieldname   = 'SOBKZ'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_out.

* number of material document
  g_s_fieldcat-fieldname   = 'MBLNR'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_take c_out.

* item in material document
  g_s_fieldcat-fieldname   = 'ZEILE'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_take c_out.

  IF bwbst = 'X'.
*   accounting document number
    g_s_fieldcat-fieldname   = 'BELNR'.
    g_s_fieldcat-ref_tabname = 'BSIM'.
    g_s_fieldcat-sp_group    = 'O'.
    PERFORM f0410_fieldcat USING c_take c_out.
  ENDIF.

* posting date in the document
  g_s_fieldcat-fieldname   = 'BUDAT'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'D'.
  PERFORM f0410_fieldcat USING c_take c_out.

* quantity
  g_s_fieldcat-fieldname   = 'MENGE'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-qfieldname  = 'MEINS'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_out.

* base unit of measure
  g_s_fieldcat-fieldname   = 'MEINS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_out.

* amount in local currency
  IF NOT bwbst IS INITIAL.            "valuated stock (standard)
    g_s_fieldcat-fieldname   = 'DMBTR'.
    g_s_fieldcat-ref_tabname = 'BSIM'.
    g_s_fieldcat-cfieldname  = 'WAERS'.
    g_s_fieldcat-sp_group    = 'M'.
    PERFORM f0410_fieldcat USING c_take c_out.

*  >>> ZMB5B 195_BRD_FS : show amount (MSEG-DMBTR) for the
*      "Storage Loc./Batch Stock" radio button (LGBST). The value is
*      already on the detail row (selected from MSEG by MBLNR/MJAHR/
*      ZEILE); only its display is enabled here. LGBST/BWBST/SBBST are
*      one mutually-exclusive radio group, so this ELSEIF targets the
*      Storage Loc./Batch Stock view only.
  ELSEIF NOT lgbst IS INITIAL.
    g_s_fieldcat-fieldname   = 'DMBTR'.
    g_s_fieldcat-ref_tabname = 'MSEG'.
    g_s_fieldcat-sp_group    = 'M'.
    PERFORM f0410_fieldcat USING c_take c_out.
*  <<< ZMB5B 195_BRD_FS
  ENDIF.

* segmentation
  IF cl_ops_switch_check=>sfsw_segmentation_02( ) EQ abap_on.
    g_s_fieldcat-fieldname   = 'SGT_SCAT'.
    g_s_fieldcat-ref_tabname = 'MSEG'.
    g_s_fieldcat-sp_group    = 'M'.
    PERFORM f0410_fieldcat USING c_take c_out.
  ENDIF.

* the following fields are always in g_s_mseg_lean but hidden in the list
* material document year
  g_s_fieldcat-fieldname   = 'MJAHR'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'D'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* fiscal year
  g_s_fieldcat-fieldname   = 'GJAHR'.
  g_s_fieldcat-ref_tabname = 'BKPF'.
  g_s_fieldcat-sp_group    = 'D'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* transaction/event type
  g_s_fieldcat-fieldname   = 'VGART'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* user name
  g_s_fieldcat-fieldname   = 'USNAM'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* entry date
  g_s_fieldcat-fieldname   = 'CPUDT'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'D'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* time of entry
  g_s_fieldcat-fieldname   = 'CPUTM'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'D'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* debit/credit indicator
  g_s_fieldcat-fieldname   = 'SHKZG'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* valuation type
  g_s_fieldcat-fieldname   = 'BWTAR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* indicator: valuation of special stock
  g_s_fieldcat-fieldname   = 'KZBWS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* batch number
  g_s_fieldcat-fieldname   = 'CHARG'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* company code
  g_s_fieldcat-fieldname   = 'BUKRS'.
  g_s_fieldcat-ref_tabname = 'T001'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

  IF gv_switch_ehp6ru = abap_true AND bwbst = 'X'.
*   G/L account
    g_s_fieldcat-fieldname   = 'HKONT'.
    g_s_fieldcat-ref_tabname = 'BSEG'.
    g_s_fieldcat-sp_group    = 'O'.
    PERFORM f0410_fieldcat USING c_take c_no_out.
  ENDIF.

* movement indicator
  g_s_fieldcat-fieldname   = 'KZBEW'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* consumption posting indicator
  g_s_fieldcat-fieldname   = 'KZVBR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* receipt indicator
  g_s_fieldcat-fieldname   = 'KZZUG'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* posting string for quantities
  g_s_fieldcat-fieldname   = 'BUSTM'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* posting string for values
  g_s_fieldcat-fieldname   = 'BUSTW'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* quantity updating in material master record
  g_s_fieldcat-fieldname   = 'MENGU'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* value updating in material master record
  g_s_fieldcat-fieldname   = 'WERTU'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* movement type group for stock analysis (ref table changed in 46B)
  g_s_fieldcat-fieldname   = 'BWAGR'.
  g_s_fieldcat-ref_tabname = 'T156Q'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* goods receipt/issue slip (hidden)
  g_s_fieldcat-fieldname   = 'XABLN'.
  g_s_fieldcat-ref_tabname = 'MKPF'.
  g_s_fieldcat-sp_group    = 'S'.
  PERFORM f0410_fieldcat USING c_take c_no_out.

* -------------------------------------------------------------------- *
* The following fields are processed only if present in working table  *
* g_t_mseg_fields (customer-exit fields, activated in                  *
* ZRM07MLBD_CUST_FIELDS). They are added with c_check (add only if the *
* field was requested) and c_no_out (hidden by default).               *
* -------------------------------------------------------------------- *

* stock type
  g_s_fieldcat-fieldname   = 'INSMK'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* vendor's account number
  g_s_fieldcat-fieldname   = 'LIFNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* customer account number
  g_s_fieldcat-fieldname   = 'KUNNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* sales order number / item (4.5B and higher)
  g_s_fieldcat-fieldname   = 'MAT_KDAUF'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

  g_s_fieldcat-fieldname   = 'MAT_KDPOS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* sales order number / item (4.0B)
  g_s_fieldcat-fieldname   = 'KDAUF'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

  g_s_fieldcat-fieldname   = 'KDPOS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* delivery schedule for sales order
  g_s_fieldcat-fieldname   = 'KDEIN'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'F'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* quantity in unit of entry
  g_s_fieldcat-fieldname   = 'ERFMG'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-qfieldname  = 'ERFME'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* unit of entry
  g_s_fieldcat-fieldname   = 'ERFME'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* quantity in purchase order price unit
  g_s_fieldcat-fieldname   = 'BPMNG'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-qfieldname  = 'BPRME'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* order price unit
  g_s_fieldcat-fieldname   = 'BPRME'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* purchase order number
  g_s_fieldcat-fieldname   = 'EBELN'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* item number of purchasing document
  g_s_fieldcat-fieldname   = 'EBELP'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* material document year (reversal)
  g_s_fieldcat-fieldname   = 'SJAHR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'D'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* number of material document (reversal)
  g_s_fieldcat-fieldname   = 'SMBLN'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* item in material document (reversal)
  g_s_fieldcat-fieldname   = 'SMBLP'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* "delivery completed" indicator
  g_s_fieldcat-fieldname   = 'ELIKZ'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* item text
  g_s_fieldcat-fieldname   = 'SGTXT'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* goods recipient
  g_s_fieldcat-fieldname   = 'WEMPF'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* unloading point
  g_s_fieldcat-fieldname   = 'ABLAD'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* business area
  g_s_fieldcat-fieldname   = 'GSBER'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* trading partner's business area
  g_s_fieldcat-fieldname   = 'PARGB'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* clearing company code
  g_s_fieldcat-fieldname   = 'PARBU'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* cost center
  g_s_fieldcat-fieldname   = 'KOSTL'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* order number
  g_s_fieldcat-fieldname   = 'AUFNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* main asset number
  g_s_fieldcat-fieldname   = 'ANLN1'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* number of reservation / dependent requirements
  g_s_fieldcat-fieldname   = 'RSNUM'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* item number of reservation / dependent requirements
  g_s_fieldcat-fieldname   = 'RSPOS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* final issue for this reservation
  g_s_fieldcat-fieldname   = 'KZEAR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* receiving/issuing material
  g_s_fieldcat-fieldname   = 'UMMAT'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* receiving/issuing plant
  g_s_fieldcat-fieldname   = 'UMWRK'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* receiving/issuing storage location
  g_s_fieldcat-fieldname   = 'UMLGO'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* receiving/issuing batch
  g_s_fieldcat-fieldname   = 'UMCHA'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* valuation type of transfer batch
  g_s_fieldcat-fieldname   = 'UMBAR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* special stock indicator for physical stock transfer
  g_s_fieldcat-fieldname   = 'UMSOK'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* goods receipt, non-valuated
  g_s_fieldcat-fieldname   = 'WEUNB'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* reason for movement
  g_s_fieldcat-fieldname   = 'GRUND'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* cost object
  g_s_fieldcat-fieldname   = 'KSTRG'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* profitability segment number (CO-PA)
  g_s_fieldcat-fieldname   = 'PAOBJNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* profit center
  g_s_fieldcat-fieldname   = 'PRCTR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* WBS element (4.5B and higher)
  g_s_fieldcat-fieldname   = 'MAT_PSPNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* WBS element (4.0B)
  g_s_fieldcat-fieldname   = 'PS_PSP_PNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* network number for account assignment
  g_s_fieldcat-fieldname   = 'NPLNR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* routing number for operations in the order
  g_s_fieldcat-fieldname   = 'AUFPL'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* order item number
  g_s_fieldcat-fieldname   = 'AUFPS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'K'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* goods receipt quantity in order unit
  g_s_fieldcat-fieldname   = 'BSTMG'.
  g_s_fieldcat-qfieldname  = 'BSTME'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* order unit
  g_s_fieldcat-fieldname   = 'BSTME'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'E'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* externally entered posting amount in local currency
  g_s_fieldcat-fieldname   = 'EXBWR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-cfieldname  = 'WAERS'.
  g_s_fieldcat-sp_group    = 'S'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* value at sales prices including VAT
  g_s_fieldcat-fieldname   = 'VKWRT'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-cfieldname  = 'WAERS'.
  g_s_fieldcat-sp_group    = 'V'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* shelf life expiration date
  g_s_fieldcat-fieldname   = 'VFDAT'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* externally entered sales value in local currency
  g_s_fieldcat-fieldname   = 'EXVKW'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-cfieldname  = 'WAERS'.
  g_s_fieldcat-sp_group    = 'S'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* partner profit center
  g_s_fieldcat-fieldname   = 'PPRCTR'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'O'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* material on which stock is managed
  g_s_fieldcat-fieldname   = 'MATBF'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* receiving/issuing material (stock managed)
  g_s_fieldcat-fieldname   = 'UMMAB'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* total valuated stock before the posting
  g_s_fieldcat-fieldname   = 'LBKUM'.
  g_s_fieldcat-qfieldname  = 'MEINS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* value of total valuated stock before the posting
  g_s_fieldcat-fieldname   = 'SALK3'.
  g_s_fieldcat-cfieldname  = 'WAERS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'B'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* price control indicator
  g_s_fieldcat-fieldname   = 'VPRSV'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'S'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* value at sales prices excluding VAT
  g_s_fieldcat-fieldname   = 'VKWRA'.
  g_s_fieldcat-cfieldname  = 'WAERS'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'S'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* original line in material document
  g_s_fieldcat-fieldname   = 'URZEI'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'S'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* quantity in unit of measure from delivery note
  g_s_fieldcat-fieldname   = 'LSMNG'.
  g_s_fieldcat-qfieldname  = 'LSMEH'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* unit of measure from delivery note
  g_s_fieldcat-fieldname   = 'LSMEH'.
  g_s_fieldcat-ref_tabname = 'MSEG'.
  g_s_fieldcat-sp_group    = 'M'.
  PERFORM f0410_fieldcat USING c_check c_no_out.

* -------------------------------------------------------------------- *
* If the field catalog contains any field with a value in currency,    *
* add the currency key WAERS to the field catalog (active or hidden).  *
* -------------------------------------------------------------------- *
  DATA: l_cnt_waers_active TYPE i,
        l_cnt_waers_total  TYPE i.

  LOOP AT fieldcat INTO g_s_fieldcat.
    CHECK g_s_fieldcat-cfieldname = 'WAERS'.
    ADD 1 TO l_cnt_waers_total.
    CHECK g_s_fieldcat-no_out IS INITIAL.
    ADD 1 TO l_cnt_waers_active.
  ENDLOOP.

  IF l_cnt_waers_active > 0.
    g_s_fieldcat-fieldname   = 'WAERS'.
    g_s_fieldcat-ref_tabname = 'T001'.
    g_s_fieldcat-sp_group    = 'M'.
    PERFORM f0410_fieldcat USING c_take c_out.
  ELSEIF l_cnt_waers_total > 0.
    g_s_fieldcat-fieldname   = 'WAERS'.
    g_s_fieldcat-ref_tabname = 'T001'.
    g_s_fieldcat-sp_group    = 'M'.
    PERFORM f0410_fieldcat USING c_take c_no_out.
  ENDIF.

* -------------------------------------------------------------------- *
* Standard SAP enhancement spot RM07MLBD_04 (IS-OIL implementation      *
* OIH_RM07MLBD adds OIL excise-duty fields as hidden) - carried         *
* automatically by the SE38/ADT program copy; not reproduced here.      *
*   ENHANCEMENT-POINT rm07mlbd_04 SPOTS es_rm07mlbd.                     *
* -------------------------------------------------------------------- *

* CWM (catch weight management) quantity fields - only when not valuated
  IF /cwm/cl_switch_check=>client( ) = /cwm/cl_switch_check=>true.
    IF bwbst <> 'X'.
      CLEAR g_s_fieldcat-no_out.
      g_s_fieldcat-fieldname   = '/CWM/MENGE'.
      g_s_fieldcat-ref_tabname = 'MSEG'.
      g_s_fieldcat-qfieldname  = '/CWM/MEINS'.
      g_s_fieldcat-sp_group    = 'M'.
      PERFORM f0410_fieldcat USING c_take c_out.
    ENDIF.

    IF bwbst <> 'X'.
      CLEAR g_s_fieldcat-no_out.
      g_s_fieldcat-fieldname   = '/CWM/MEINS'.
      g_s_fieldcat-ref_tabname = 'MSEG'.
      g_s_fieldcat-sp_group    = 'M'.
      PERFORM f0410_fieldcat USING c_take c_out.
    ENDIF.

*   keep header values intact even if user reduces visible fields
    layout-min_linesize = 85.

*   use reference to /CWM/VALUM for the base unit
    IF bwbst = 'X'.
      LOOP AT fieldcat INTO g_s_fieldcat.
        CHECK g_s_fieldcat-fieldname = 'MEINS'.
        g_s_fieldcat-ref_tabname   = 'MARA'.
        g_s_fieldcat-ref_fieldname = '/CWM/VALUM'.
        MODIFY fieldcat FROM g_s_fieldcat.
      ENDLOOP.
    ENDIF.
  ENDIF.

* -------------------------------------------------------------------- *
* Standard SAP enhancement point (carried by the program copy):         *
*   ENHANCEMENT-POINT ehp605_rm07mlbd_15 SPOTS es_rm07mlbd.             *
* -------------------------------------------------------------------- *

ENDFORM.                    "f0400_create_fieldcat
