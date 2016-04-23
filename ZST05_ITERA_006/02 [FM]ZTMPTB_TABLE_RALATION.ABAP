FUNCTION ZTMPTB_TABLE_RALATION.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  TABLES
*"      IT_MAIN_RECORD_OLD OPTIONAL
*"      ET_MAIN_RECORD_NEW OPTIONAL
*"      ET_CELLS OPTIONAL
*"----------------------------------------------------------------------

"&---------------------------------------
"& ZST05_I06:/ TABLE RALATION ANALYZER
"& Boris Town
"&---------------------------------------

"&---------------------------------------
"& 01 Global Definition
"&---------------------------------------
  DATA REF_SQL_EXECUTOR TYPE REF TO CL_HDB_SQL_EXECUTOR.
  DATA REF_SYSTEM TYPE REF TO CL_DB6_SYS.
  DATA LT_ZTMPTB_MAIN_RECORD TYPE TABLE OF ZTMPTB_MAIN_RECORD.
  DATA LS_ZTMPTB_MAIN_RECORD TYPE ZTMPTB_MAIN_RECORD.
  DATA LT_ZTMPTB_MAIN_RECORD_OLD TYPE TABLE OF ST05_MAIN_RECORD.
  DATA: LS_ZTMPTB_MAIN_RECORD_OLD TYPE ST05_MAIN_RECORD,
        LR_RESULT_DESCR  TYPE REF TO CL_ABAP_STRUCTDESCR,
        LR_RESULT        TYPE REF TO DATA.
  DATA: L_TABIX TYPE I.
"&---------------------------------------
"& 02 Init SQL_EXECUTOR
"&---------------------------------------
  CREATE OBJECT REF_SQL_EXECUTOR.
  REF_SYSTEM = CL_DB6_SYS=>GET_SYS_REF( SYSTEM_ID     = SY-SYSID
                                        IGNORE_ERRORS = ''
                                        SYNCHRONIZE   = '' ).

  LT_ZTMPTB_MAIN_RECORD_OLD[] = IT_MAIN_RECORD_OLD[].

"&---------------------------------------
"& 03 Get statment and variable list
"&---------------------------------------
  TYPES: BEGIN OF LY_STATEMENT,
           SOURCE_INDEX TYPE I,
           SELECT_SQL TYPE STRING,
           VARIABLES TYPE ALPF_STRING_TAB,
        END OF LY_STATEMENT.

  DATA: LT_STATEMENT TYPE TABLE OF LY_STATEMENT.
  DATA: LS_STATEMENT TYPE LY_STATEMENT.

  LOOP AT LT_ZTMPTB_MAIN_RECORD_OLD INTO LS_ZTMPTB_MAIN_RECORD_OLD.
    LS_STATEMENT-SOURCE_INDEX = SY-TABIX.
    IF LS_ZTMPTB_MAIN_RECORD_OLD-STATEMENT_WITH_VALUES CP 'SELECT*'.
      CALL FUNCTION 'ZTMPTB_RESTORE_SQL'
        EXPORTING
          IV_STATEMENT            = LS_ZTMPTB_MAIN_RECORD-STATEMENT_WITH_NAMES
          IV_VARIABLES            = LS_ZTMPTB_MAIN_RECORD-VARIABLES
        IMPORTING
          EV_SQL                  = LS_STATEMENT-SELECT_SQL
          ET_VARIABLE_VALUE       = LS_STATEMENT-VARIABLES
        EXCEPTIONS
          REMARKS_NOT_MATCH       = 1
          OTHERS                  = 2
                .
      IF SY-SUBRC EQ 0.
        APPEND LS_STATEMENT TO LT_STATEMENT.
        CLEAR LS_STATEMENT.
      ENDIF.
    ENDIF.
  ENDLOOP.
  SORT LT_STATEMENT BY SOURCE_INDEX.

  LOOP AT LT_ZTMPTB_MAIN_RECORD_OLD INTO LS_ZTMPTB_MAIN_RECORD_OLD.
    L_TABIX = SY-TABIX.
    MOVE-CORRESPONDING LS_ZTMPTB_MAIN_RECORD_OLD TO LS_ZTMPTB_MAIN_RECORD.
    IF LS_ZTMPTB_MAIN_RECORD-STATEMENT_WITH_VALUES CP 'SELECT*'.
      "CL_HDB_ACTION_SQL_EDITOR IF_DB6_ACTION_CONTROLLER~REFRESH_VIEW
      CLEAR LR_RESULT_DESCR.
      CLEAR LR_RESULT.
      READ TABLE LT_STATEMENT INTO LS_STATEMENT WITH KEY SOURCE_INDEX = L_TABIX BINARY SEARCH .
      IF SY-SUBRC EQ 0.
        "EXECUTE QUERY
        REF_SQL_EXECUTOR->EXEC_QUERY_DYN( EXPORTING IM_STATEMENT    = LS_STATEMENT-SELECT_SQL
                                                IM_CURSOR_SIZE  = '250'
                                                IM_SYSTEM       = REF_SYSTEM
                                                IM_CHECK        = ABAP_TRUE
                                                IM_LOGGING      = ABAP_TRUE
                                      IMPORTING EX_STRUCTDESCR  = LR_RESULT_DESCR
                                                EX_RESULT_REF   = LR_RESULT ).
"&---------------------------------------
"& 5 Create receipt structure
"&---------------------------------------
        FIELD-SYMBOLS <LT_OUTTAB> TYPE STANDARD TABLE.
        FIELD-SYMBOLS <LS_OUTTAB> TYPE ANY.
        DATA LR_RESULT_LINE TYPE REF TO DATA.
        DATA LT_COMP_TAB TYPE CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE.
        DATA LS_COMP_FLD TYPE CL_ABAP_STRUCTDESCR=>COMPONENT.

        UNASSIGN: <LT_OUTTAB>, <LS_OUTTAB>.

        CREATE DATA LR_RESULT_LINE TYPE HANDLE LR_RESULT_DESCR.
        ASSIGN LR_RESULT_LINE->* TO <LS_OUTTAB>.

        CLEAR LT_COMP_TAB.
        LT_COMP_TAB = LR_RESULT_DESCR->GET_COMPONENTS( ).
"&---------------------------------------
"& 6 Assign result table
"&---------------------------------------
        FIELD-SYMBOLS <L_FLD> TYPE ANY.
        DATA L_STR_FLD TYPE CHAR255.

        ASSIGN LR_RESULT->* TO <lt_outtab>.
"&---------------------------------------
"& 7 Find field relation
"&---------------------------------------
        LOOP AT <LT_OUTTAB> ASSIGNING <LS_OUTTAB>.
          IF LS_ZTMPTB_MAIN_RECORD-ZZREMARK02 IS INITIAL.
            LOOP AT LT_COMP_TAB INTO LS_COMP_FLD.
              ASSIGN COMPONENT LS_COMP_FLD-NAME OF STRUCTURE <LS_OUTTAB> TO <L_FLD>.
              WRITE <L_FLD> TO L_STR_FLD.
              IF LS_ZTMPTB_MAIN_RECORD-ZZREMARK02 IS INITIAL.
                LS_ZTMPTB_MAIN_RECORD-ZZREMARK02 =  L_STR_FLD.
              ELSE.
                CONCATENATE LS_ZTMPTB_MAIN_RECORD-ZZREMARK02 '|' L_STR_FLD
                INTO LS_ZTMPTB_MAIN_RECORD-ZZREMARK02 SEPARATED BY SPACE .
              ENDIF.
            ENDLOOP.
            CONDENSE LS_ZTMPTB_MAIN_RECORD-ZZREMARK02.
*            WRITE <LS_OUTTAB> TO LS_ZTMPTB_MAIN_RECORD-ZZREMARK01 .
            LS_ZTMPTB_MAIN_RECORD-ZZREMARK01 = 'X'.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    APPEND LS_ZTMPTB_MAIN_RECORD TO LT_ZTMPTB_MAIN_RECORD.
    CLEAR LS_ZTMPTB_MAIN_RECORD.
  ENDLOOP.
  ET_MAIN_RECORD_NEW[] = LT_ZTMPTB_MAIN_RECORD[].

ENDFUNCTION.
