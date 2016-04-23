FUNCTION ZTMPTB_TABLE_RALATION.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  TABLES
*"      IT_MAIN_RECORD_OLD OPTIONAL
*"      ET_MAIN_RECORD_NEW OPTIONAL
*"      ET_CELLS OPTIONAL
*"----------------------------------------------------------------------

"&---------------------------------------
"& ZST05_I05:/ TABLE RALATION ANALYZER
"& Boris Town
"&---------------------------------------

  DATA REF_SQL_EXECUTOR TYPE REF TO CL_HDB_SQL_EXECUTOR.
  DATA REF_SYSTEM TYPE REF TO CL_DB6_SYS.
  DATA LT_ZTMPTB_MAIN_RECORD TYPE TABLE OF ZTMPTB_MAIN_RECORD.
  DATA LS_ZTMPTB_MAIN_RECORD TYPE ZTMPTB_MAIN_RECORD.
  DATA LT_ZTMPTB_MAIN_RECORD_OLD TYPE TABLE OF ST05_MAIN_RECORD.
  DATA: LS_ZTMPTB_MAIN_RECORD_OLD TYPE ST05_MAIN_RECORD,
        LR_RESULT_DESCR  TYPE REF TO CL_ABAP_STRUCTDESCR,
        lr_result        TYPE REF TO data.

  CREATE OBJECT REF_SQL_EXECUTOR.

  REF_SYSTEM = CL_DB6_SYS=>GET_SYS_REF( SYSTEM_ID     = SY-SYSID
                                        IGNORE_ERRORS = ''
                                        SYNCHRONIZE   = '' ).

  LT_ZTMPTB_MAIN_RECORD_OLD[] = IT_MAIN_RECORD_OLD[].
  LOOP AT LT_ZTMPTB_MAIN_RECORD_OLD INTO LS_ZTMPTB_MAIN_RECORD_OLD.
    MOVE-CORRESPONDING LS_ZTMPTB_MAIN_RECORD_OLD TO LS_ZTMPTB_MAIN_RECORD.
    IF LS_ZTMPTB_MAIN_RECORD-STATEMENT_WITH_VALUES CP 'SELECT*'.
      "CL_HDB_ACTION_SQL_EDITOR IF_DB6_ACTION_CONTROLLER~REFRESH_VIEW
      CLEAR LR_RESULT_DESCR.
      CLEAR LR_RESULT.
      DATA L_SQL TYPE STRING.
      CLEAR L_SQL.
      CALL FUNCTION 'ZTMPTB_RESTORE_SQL'
        EXPORTING
          IV_STATEMENT            = LS_ZTMPTB_MAIN_RECORD-STATEMENT_WITH_NAMES
          IV_VARIABLES            = LS_ZTMPTB_MAIN_RECORD-VARIABLES
        IMPORTING
          EV_SQL                  = L_SQL
        EXCEPTIONS
          REMARKS_NOT_MATCH       = 1
          OTHERS                  = 2
                .
      IF SY-SUBRC <> 0.

        REF_SQL_EXECUTOR->EXEC_QUERY_DYN( EXPORTING IM_STATEMENT    = L_SQL
                                                IM_CURSOR_SIZE  = '250'
                                                IM_SYSTEM       = REF_SYSTEM
                                                IM_CHECK        = ABAP_TRUE
                                                IM_LOGGING      = ABAP_TRUE
                                      IMPORTING EX_STRUCTDESCR  = LR_RESULT_DESCR
                                                EX_RESULT_REF   = LR_RESULT ).
        LS_ZTMPTB_MAIN_RECORD-ZZREMARK01 = 'X'.
      ENDIF.
    ENDIF.
    APPEND LS_ZTMPTB_MAIN_RECORD TO LT_ZTMPTB_MAIN_RECORD.
    CLEAR LS_ZTMPTB_MAIN_RECORD.
  ENDLOOP.
  ET_MAIN_RECORD_NEW[] = LT_ZTMPTB_MAIN_RECORD[].

ENDFUNCTION.
