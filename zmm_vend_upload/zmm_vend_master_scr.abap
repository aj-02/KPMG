*&---------------------------------------------------------------------*
*& Include          ZMM_VEND_MASTER_SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&                SELECTION SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-101.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : rb_new RADIOBUTTON GROUP r1 USER-COMMAND uc1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 4(20) TEXT-001 FOR FIELD rb_new.
    PARAMETERS : rb_chg RADIOBUTTON GROUP r1.
    SELECTION-SCREEN COMMENT (40) TEXT-003 FOR FIELD rb_chg.
    PARAMETERS : rb_ext RADIOBUTTON GROUP r1.
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
