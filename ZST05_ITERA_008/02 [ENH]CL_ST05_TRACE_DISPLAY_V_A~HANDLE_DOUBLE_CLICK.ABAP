ENHANCEMENT 1  ZTMPTB_I08_2.    "active version
*ZST05 HANDLE DOUBLE CLICK - BORIS TOWN 2016-5-8
*ENHANCEMENT POINT: BEGIN OF CL_ST05_TRACE_DISPLAY_V_A~HANDLE_DOUBLE_CLICK
*SYSTEM VERSION: NW 7.5 FOR S4HANA OP 1511
  "01 LOGIC ONLY FOR TCODE ZST05_NEW 2016-5-8
  IF SY-TCODE EQ 'ZST05'.
    "02 IF CLICKED ZZREMARK01( Query Result ) 2016-5-8
    IF E_COLUMN-FIELDNAME EQ 'ZZREMARK01'.
    " 03 STANDARD ORIGINAL CODE 2016-5-8
    " Handle ALV Grid Event DOUBLE_CLICK.
      IF (     'TABLE'  =  me->display_properties-name
           AND 'OBJECT' <> e_column-fieldname ).
        RETURN.
      ENDIF.

      "04 get the selected cells from the view 2016-5-8
      DATA : ZTMPTB_CELL_ID_TABLE  TYPE LVC_T_CELL.
      ZTMPTB_CELL_ID_TABLE = ME->GET_SELECTED_CELLS( ).

      "05 exclude header row cells 2016-5-8
      DELETE  ZTMPTB_CELL_ID_TABLE
        WHERE  ROW_ID-INDEX = '0000000000'.

      "06 Get table for record number 2016-5-8
      DATA : ZTMPTB_RECORD_NUMBER_TABLE  TYPE PTC_RECORD_NUMBERS.
      FIELD-SYMBOLS : <ZTMPTB_record_number>  TYPE PTC_RECORD_NUMBER.
      ZTMPTB_RECORD_NUMBER_TABLE = ME->GET_RECORD_NUMBER_TABLE( ZTMPTB_CELL_ID_TABLE ).

      "07 Get Main Record 2016-5-8
      FIELD-SYMBOLS : <ZTMPTB_RECORD_ANY> TYPE ANY TABLE.
      FIELD-SYMBOLS : <ZTMPTB_RECORD_LINE> TYPE ZTMPTB_MAIN_RECORD.

      ASSIGN ME->GRID_TABLE_REF->* TO <ZTMPTB_RECORD_ANY>.

      "07 Convert Main Record to type ZTMPTB_MAIN_RECORD_TABLE 2016-5-8
      FIELD-SYMBOLS : <ZTMPTB_RECORD_TAB> TYPE ZTMPTB_MAIN_RECORD_TABLE.
      DATA : ZTMPTB_LT_RECORD_TAB TYPE REF TO ZTMPTB_MAIN_RECORD_TABLE.

      CREATE DATA ZTMPTB_LT_RECORD_TAB.

      ASSIGN ZTMPTB_LT_RECORD_TAB->* TO <ZTMPTB_RECORD_TAB>.

      <ZTMPTB_RECORD_TAB> = <ZTMPTB_RECORD_ANY>.

       "08 Get selected line 2016-5-8
       LOOP AT ZTMPTB_RECORD_NUMBER_TABLE
         ASSIGNING <ZTMPTB_RECORD_NUMBER>.
         READ TABLE <ZTMPTB_RECORD_TAB> ASSIGNING <ZTMPTB_RECORD_LINE>
         WITH KEY RECORD_NUMBER = <ZTMPTB_RECORD_NUMBER> BINARY SEARCH.
         IF SY-SUBRC EQ 0.
           "09 IF ZZREMARK01 IS NOT INITIAL 2016-5-8
           IF <ZTMPTB_RECORD_LINE>-ZZREMARK01 IS NOT INITIAL.
             "10 Get SQL statement 2016-5-8
             DATA ZTMPTB_SELECT_SQL TYPE STRING.
             CLEAR ZTMPTB_SELECT_SQL.
             CALL FUNCTION 'ZTMPTB_RESTORE_SQL'
              EXPORTING
                IV_STATEMENT            = <ZTMPTB_RECORD_LINE>-STATEMENT_WITH_NAMES
                IV_VARIABLES            = <ZTMPTB_RECORD_LINE>-VARIABLES
              IMPORTING
                EV_SQL                  = ZTMPTB_SELECT_SQL
              EXCEPTIONS
                REMARKS_NOT_MATCH       = 1
                OTHERS                  = 2
                      .
            IF SY-SUBRC EQ 0.
              "11 Split statment string to string tables
              DATA ZTMPTB_OUT_LINES TYPE TABLE OF STRING.
              DATA ZTMPTB_LONGEST_CHAR(65535) TYPE C.
              ZTMPTB_LONGEST_CHAR = ZTMPTB_SELECT_SQL.
              CALL FUNCTION 'RKD_WORD_WRAP'
                EXPORTING
                  TEXTLINE                  = ZTMPTB_LONGEST_CHAR
*                 DELIMITER                 = ' '
                  OUTPUTLEN                 = 255
*               IMPORTING
*                 OUT_LINE1                 =
*                 OUT_LINE2                 =
*                 OUT_LINE3                 =
                TABLES
                  OUT_LINES                 = ZTMPTB_OUT_LINES
                EXCEPTIONS
                  OUTPUTLEN_TOO_LARGE       = 1
                  OTHERS                    = 2
                        .
              IF SY-SUBRC <> 0.
* Implement suitable error handling here
              ENDIF.

             "12 Import SQL statement to memory 2016-5-8
              EXPORT P_STATEMTN = ZTMPTB_OUT_LINES TO MEMORY ID 'ZTMPTB_ZST05_SQL'.
              "13 Call Transaction 'ZDBACOCKPIT_SQL' 2016-5-8
              CALL TRANSACTION 'ZDBACOCKPIT_SQL'.
              "14 Exit function 2016-5-8
              RETURN.
            ENDIF.
           ENDIF.
         ENDIF.
       ENDLOOP.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
