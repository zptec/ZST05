FUNCTION ZTMPTB_RESTORE_SQL.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IV_STATEMENT)
*"     REFERENCE(IV_VARIABLES)
*"  EXPORTING
*"     REFERENCE(EV_SQL)
*"     REFERENCE(ET_VARIABLE_VALUE) TYPE  ALPF_STRING_TAB
*"     REFERENCE(ET_KEYS) TYPE  ALPF_STRING_TAB
*"  EXCEPTIONS
*"      REMARKS_NOT_MATCH
*"----------------------------------------------------------------------

"&---------------------------------------
"& ZST05_I06:/ Restore SQL statement
"& Boris Town
"&---------------------------------------
"& Sample Input:
"& SELECT DISTINCT  "ENHNAME" FROM "ENHOBJ" WHERE "OBJ_TYPE" = ? AND "OBJ_NAME" = ? AND "STATE" <> ? AND "ELEMUSAGE" IN ( ? , ? , ? )
"& CH&4&CLAS&CH&120&CL_PTC_C_ALV                                                                                                            &CH&1&R&CH&4&EXTO&CH&4&RDEF&CH&4&REDO&
"&
"& Sample Output:
"& SELECT DISTINCT "ENHNAME" FROM "ENHOBJ" WHERE "OBJ_TYPE" = 'CLAS' AND "OBJ_NAME" = 'CL_PTC_C_ALV' AND "STATE" <> 'R' AND "ELEMUSAGE" IN ( 'EXTO' , 'RDEF' , 'REDO' )
"&
"& ET_VARIABLE_VALUE:
"& CLAS
"& CL_PTC_C_ALV
"& R
"& EXTO
"& RDEF
"& REDO
"&
"& ET_KEYS
"& OBJ_TYPE
"& OBJ_NAME
"& STATE
"& ELEMUSAGE
"& ELEMUSAGE
"& ELEMUSAGE
"&---------------------------------------

"&---------------------------------------
"& 1 Split Variables String
"&---------------------------------------
DATA LT_VARIABLE_STRINGS TYPE TABLE OF STRING.
SPLIT IV_VARIABLES AT '&' INTO TABLE LT_VARIABLE_STRINGS.
"&---------------------------------------
"& 2 Get each varible
"&---------------------------------------
DATA LT_VARIABLE_WITH_MARKS TYPE TABLE OF STRING.
DATA LT_VARIABLE_STRING TYPE STRING.
DATA L_TABIX TYPE I.
DATA L_MOD3 TYPE I.
CLEAR L_TABIX.
CLEAR ET_VARIABLE_VALUE.
CLEAR LT_VARIABLE_WITH_MARKS.
DATA STRLEN_VAR TYPE I.
DATA CHAR02_VAR TYPE CHAR2.
LOOP AT LT_VARIABLE_STRINGS INTO LT_VARIABLE_STRING.
  ADD 1 TO L_TABIX.
  L_MOD3 = L_TABIX MOD 3.
  IF L_MOD3 EQ 0.
    CONDENSE LT_VARIABLE_STRING.
    STRLEN_VAR = STRLEN( LT_VARIABLE_STRING ).
    IF STRLEN_VAR GE 2. "Hexadecimal data
      CHAR02_VAR = LT_VARIABLE_STRING(2).
      IF CHAR02_VAR EQ '0x' AND LT_VARIABLE_STRING CO '0x123456789ABCDEF'.
        SUBTRACT 2 FROM STRLEN_VAR.
        LT_VARIABLE_STRING = LT_VARIABLE_STRING+2(STRLEN_VAR).
      ENDIF.
    ENDIF.
    APPEND LT_VARIABLE_STRING TO ET_VARIABLE_VALUE.
    CONCATENATE '''' LT_VARIABLE_STRING ''''  INTO LT_VARIABLE_STRING.
    CONDENSE LT_VARIABLE_STRING.
    APPEND LT_VARIABLE_STRING TO LT_VARIABLE_WITH_MARKS.
  ENDIF.
ENDLOOP.
"&---------------------------------------
"& 3 Search for all question mark in statement
"&---------------------------------------
DATA: STATEMENT_MARKS TYPE match_result_tab.
FIND ALL OCCURRENCES OF '?' IN IV_STATEMENT RESULTS STATEMENT_MARKS.

"&---------------------------------------
"& 3.1 Split statment by space
"&---------------------------------------
DATA LT_ELEMENTS TYPE TABLE OF STRING.
DATA LS_ELEMENTS TYPE STRING.
SPLIT IV_STATEMENT AT SPACE INTO TABLE LT_ELEMENTS.
DATA: BEGIN OF LT_ELEMENTS_EX OCCURS 1,
        STMT_ELEM TYPE ALPFSTRING,
        V_INDEX TYPE I,"VARIABLE INDEX
        P_INDEX TYPE I,"PARAMETER INDEX
      END OF LT_ELEMENTS_EX.

DATA CURRENT_INDEX TYPE I.
CLEAR CURRENT_INDEX.
LOOP AT LT_ELEMENTS INTO LS_ELEMENTS.
  LT_ELEMENTS_EX-STMT_ELEM = LS_ELEMENTS.
  IF LS_ELEMENTS EQ '?'.
    ADD 1 TO CURRENT_INDEX.
    LT_ELEMENTS_EX-V_INDEX = CURRENT_INDEX.
  ENDIF.
  APPEND LT_ELEMENTS_EX.
  CLEAR LT_ELEMENTS_EX.
ENDLOOP.
"&---------------------------------------
"& 3.2 Mark parameter
"&---------------------------------------
DATA LOOP_INDEX TYPE I.
DATA SEARCHING_PAR TYPE C.
LOOP_INDEX = LINES( LT_ELEMENTS_EX[] ).

WHILE LOOP_INDEX GT 0.
  READ TABLE LT_ELEMENTS_EX INDEX LOOP_INDEX.
  IF SY-SUBRC EQ 0.
    IF LT_ELEMENTS_EX-STMT_ELEM EQ '?'.
      SEARCHING_PAR = 'X'.
      CURRENT_INDEX = LT_ELEMENTS_EX-V_INDEX.
    ELSEIF SEARCHING_PAR = 'X' AND LT_ELEMENTS_EX-STMT_ELEM CP '"*'.
      CLEAR SEARCHING_PAR.
      LT_ELEMENTS_EX-P_INDEX = CURRENT_INDEX.
    ENDIF.
    MODIFY LT_ELEMENTS_EX INDEX LOOP_INDEX.
  ENDIF.
  SUBTRACT 1 FROM LOOP_INDEX.
ENDWHILE.

"&---------------------------------------
"& 3.3 Fetch Parameters
"&---------------------------------------
DATA L_VARIABLE_INDEX TYPE I.
LOOP AT ET_VARIABLE_VALUE INTO LT_VARIABLE_STRING.
  L_VARIABLE_INDEX = SY-TABIX.
  LOOP_INDEX = LINES( LT_ELEMENTS_EX[] ).
  WHILE LOOP_INDEX GT 0.
    READ TABLE LT_ELEMENTS_EX INDEX LOOP_INDEX.
    IF SY-SUBRC EQ 0.
      IF LT_ELEMENTS_EX-P_INDEX NE SPACE
        AND LT_ELEMENTS_EX-P_INDEX LE L_VARIABLE_INDEX.
        APPEND LT_ELEMENTS_EX-STMT_ELEM TO ET_KEYS.
        EXIT.
      ENDIF.
    ENDIF.
    SUBTRACT 1 FROM LOOP_INDEX.
  ENDWHILE.
ENDLOOP.
"&---------------------------------------
"& 3.4 Get Final Keys
"&---------------------------------------
DATA ES_KEYS LIKE LINE OF ET_KEYS.
DATA KEY_LENGTH TYPE I.
LOOP AT ET_KEYS INTO ES_KEYS.
  KEY_LENGTH = STRLEN( ES_KEYS ) - 2.
  ES_KEYS = ES_KEYS+1(KEY_LENGTH).
  MODIFY ET_KEYS FROM ES_KEYS.
ENDLOOP.

"&---------------------------------------
"& 4 Put variable into question mark
"&---------------------------------------
DATA L_LAST_OFFSET TYPE I.
DATA L_STRLEN TYPE I.
DATA L_SEGMENT_LENGTH TYPE I.
DATA: STATEMENT_MARK TYPE MATCH_RESULT.
CLEAR L_LAST_OFFSET.
CLEAR: EV_SQL.
L_STRLEN = STRLEN( IV_STATEMENT ).
LOOP AT STATEMENT_MARKS INTO STATEMENT_MARK.
  L_TABIX  = SY-TABIX.
  L_SEGMENT_LENGTH = STATEMENT_MARK-OFFSET - L_LAST_OFFSET.
  CONCATENATE EV_SQL IV_STATEMENT+L_LAST_OFFSET(L_SEGMENT_LENGTH)
  INTO EV_SQL SEPARATED BY SPACE.
  READ TABLE LT_VARIABLE_WITH_MARKS INTO LT_VARIABLE_STRING INDEX L_TABIX.
  IF SY-SUBRC NE 0.
    RAISE REMARKS_NOT_MATCH.
    "Question Marks & Variables not match
  ENDIF.
  CONCATENATE EV_SQL LT_VARIABLE_STRING INTO EV_SQL SEPARATED BY SPACE.
  L_LAST_OFFSET = STATEMENT_MARK-OFFSET + STATEMENT_MARK-LENGTH.
"&---------------------------------------
"& 5 Get Next Question mark
"&---------------------------------------
ENDLOOP.

"&---------------------------------------
"& 6 Generate Full statement
"&---------------------------------------
L_SEGMENT_LENGTH = L_STRLEN - L_LAST_OFFSET.
CONCATENATE EV_SQL IV_STATEMENT+L_LAST_OFFSET(L_SEGMENT_LENGTH) INTO EV_SQL.
CONDENSE EV_SQL.

ENDFUNCTION.
