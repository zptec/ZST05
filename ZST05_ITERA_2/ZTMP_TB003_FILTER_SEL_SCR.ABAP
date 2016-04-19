" Selection Screen for ST05 Trace Display (layout and events)

"=======================================================================

" selection screen layout
*SELECTION-SCREEN  BEGIN OF SCREEN 0001.

  PARAMETERS :
    p_GUID  TYPE SYSUUID_X16  MODIF ID id.

  " trace types
  SELECTION-SCREEN  BEGIN OF BLOCK type  WITH FRAME TITLE text-100.
    SELECTION-SCREEN  BEGIN OF LINE.
      SELECTION-SCREEN  POSITION 01.
      PARAMETERS : p_sql AS CHECKBOX.
      SELECTION-SCREEN  COMMENT  4(20) text-101 FOR FIELD p_sql.
      SELECTION-SCREEN  POSITION 33.
      PARAMETERS : p_buf AS CHECKBOX.
      SELECTION-SCREEN  COMMENT 37(20) text-102 FOR FIELD p_buf.
      SELECTION-SCREEN  POSITION 66.
      PARAMETERS : p_enq AS CHECKBOX.
      SELECTION-SCREEN  COMMENT 70(20) text-103 FOR FIELD p_enq.
    SELECTION-SCREEN  END OF LINE.
    SELECTION-SCREEN  BEGIN OF LINE.
      SELECTION-SCREEN  POSITION 01.
      PARAMETERS : p_rfc AS CHECKBOX.
      SELECTION-SCREEN  COMMENT  4(20) text-104 FOR FIELD p_rfc.
      SELECTION-SCREEN  POSITION 33.
      PARAMETERS : p_http AS CHECKBOX.
      SELECTION-SCREEN  COMMENT 37(20) text-105 FOR FIELD p_http.
      SELECTION-SCREEN  POSITION 66.
    SELECTION-SCREEN  END OF LINE.
    SELECTION-SCREEN  BEGIN OF LINE.
      SELECTION-SCREEN  POSITION 01.
      PARAMETERS : p_apc AS CHECKBOX.
      SELECTION-SCREEN  COMMENT  4(20) text-106 FOR FIELD p_apc.
      SELECTION-SCREEN  POSITION 33.
      PARAMETERS : p_amc AS CHECKBOX.
      SELECTION-SCREEN  COMMENT 37(20) text-107 FOR FIELD p_amc.
      SELECTION-SCREEN  POSITION 66.
    SELECTION-SCREEN  END OF LINE.

  SELECTION-SCREEN  END OF BLOCK type.

  " trace period
  SELECTION-SCREEN  BEGIN OF BLOCK time  WITH FRAME TITLE text-200.
    SELECTION-SCREEN  BEGIN OF LINE.
      SELECTION-SCREEN  COMMENT  1(12) text-201 FOR FIELD fromdate.
      SELECTION-SCREEN  POSITION 33.
      PARAMETERS : fromdate TYPE ST05_TRACE_START_DATE.
      SELECTION-SCREEN  COMMENT 52(4)  text-203 FOR FIELD todate.
      SELECTION-SCREEN  POSITION 58.
      PARAMETERS : todate TYPE ST05_TRACE_END_DATE.
    SELECTION-SCREEN  END OF LINE.
    SELECTION-SCREEN  BEGIN OF LINE.
      SELECTION-SCREEN  COMMENT  1(12) text-202 FOR FIELD fromtime.
      SELECTION-SCREEN  POSITION 33.
      PARAMETERS : fromtime TYPE ST05_TRACE_START_TIME.
      SELECTION-SCREEN  COMMENT 42(1)  text-204 FOR FIELD from_ms.
      SELECTION-SCREEN  POSITION 44.
      PARAMETERS : from_ms  TYPE C  LENGTH 3  DEFAULT '000'.                  "#EC SEL_WRONG
      SELECTION-SCREEN  COMMENT 52(4)  text-203 FOR FIELD totime.
      SELECTION-SCREEN  POSITION 58.
      PARAMETERS : totime TYPE ST05_TRACE_END_TIME.
      SELECTION-SCREEN  COMMENT 67(1)  text-204 FOR FIELD to_ms.
      SELECTION-SCREEN  POSITION 69.
      PARAMETERS : to_ms  TYPE C  LENGTH 3  DEFAULT '999'.                    "#EC SEL_WRONG
    SELECTION-SCREEN  END OF LINE.
  SELECTION-SCREEN  END OF BLOCK time.

    " filters / restrictions
    SELECTION-SCREEN  BEGIN OF BLOCK res  WITH FRAME TITLE text-300.
      DATA :  g_client        TYPE ST05_CLIENT,
              g_user          TYPE ST05_USER_NAME,
              g_object        TYPE ST05_OBJECT,
              g_duration      TYPE ST05_DURATION,
              g_operation     TYPE ST05_OPERATION,
              g_con_name      TYPE ST05_DB_CONNECTION,
              g_con_id        TYPE ST05_DB_CONNECTION_ID,
              g_wp_id         TYPE ST05_WP_ID,
              g_trans_id      TYPE ST05_TRANS_ID,
              g_epp_root_ID   TYPE ST05_EPP_ROOT_ID,
              g_epp_conn_ID   TYPE ST05_EPP_CONN_ID,
              g_epp_conn_cnt  TYPE ST05_EPP_CONN_CNT.
      SELECT-OPTIONS :
        client    FOR g_client        NO INTERVALS  NO-EXTENSION            MATCHCODE OBJECT ST05_CLIENT_ESH  MODIF ID CLI,
        user      FOR g_user          NO INTERVALS  MEMORY ID ST05_TR_USER  MATCHCODE OBJECT user_comp,
        object    FOR g_object        NO INTERVALS,
        duration  FOR g_duration      NO INTERVALS,
        operatio  FOR g_operation     NO INTERVALS,
        con_name  FOR g_con_name      NO INTERVALS,
        con_id    FOR g_con_id        NO INTERVALS,
        wp_id     FOR g_wp_id         NO INTERVALS,
        trans_id  FOR g_trans_id      NO INTERVALS,
        root_ID   FOR g_epp_root_ID   NO INTERVALS,
        conn_ID   FOR g_epp_conn_ID   NO INTERVALS,
        conn_cnt  FOR g_epp_conn_cnt  NO INTERVALS.
      SELECTION-SCREEN SKIP.
      PARAMETERS : max_rec  TYPE ST05_TRACE_RECORD_NUMBER  DEFAULT 5000.
    SELECTION-SCREEN    END OF BLOCK res.

    " program, include, and line number as very restrictive filter for SQL monitor
    SELECTION-SCREEN  BEGIN OF BLOCK sql  WITH FRAME TITLE text-400.
    PARAMETERS : program  TYPE PTC_PROGRAM_NAME       DEFAULT ''  MODIF ID sql,
                 include  TYPE ST05_INCLUDE_NAME      DEFAULT ''  MODIF ID sql,
                 line     TYPE ST05_ABAP_LINE_NUMBER              MODIF ID sql.
    SELECTION-SCREEN  END   OF BLOCK sql.

    " flags for progress indicator and for continuation popup if maximum
    " number of trace records is exceeded
    PARAMETERS : progress  TYPE ST05_BOOLEAN               MODIF ID exp,
                 popup     TYPE ST05_BOOLEAN  DEFAULT 'X'  MODIF ID exp.

    " command to be executed via SUBMIT REPORT
    PARAMETERS : command  TYPE SYUCOMM  DEFAULT ''  MODIF ID no.

    " custom buttons
    SELECTION-SCREEN: FUNCTION KEY 1,            " display trace reords: details
                      FUNCTION KEY 2,            " display trace reords: structure-identical
                      FUNCTION KEY 3,            " display trace summary
                      FUNCTION KEY 4.            " save trace records in DB

*  SELECTION-SCREEN  END OF SCREEN 0001.
" end of selection screen layout

"=======================================================================

" selection screen events
" 'PBO'
AT SELECTION-SCREEN  OUTPUT.
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Raise_PBO( ).

" 'PAI'
AT SELECTION-SCREEN  ON EXIT-COMMAND.
  IF (      sy-ucomm <> 'GET'
       AND  sy-ucomm <> 'VSHO'
       AND  sy-ucomm <> 'SCRH' ).       " For some unknown reason these are EXIT commands!
    CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Raise_EXIT_COMMAND( sy-ucomm ).
    cl_PTC_MVC=>Delete_Controller( 'Trace Record Filter' ).                   "#EC NOTEXT
    FREE  Controller.
  ENDIF.

AT SELECTION-SCREEN  ON BLOCK type.

AT SELECTION-SCREEN  ON BLOCK time.

AT SELECTION-SCREEN  ON fromdate.
  " verify that start date is not in the future
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'fromdate' ).     "#EC NOTEXT
AT SELECTION-SCREEN  ON fromtime.
  " verify that start time is not in the future
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'fromtime' ).     "#EC NOTEXT
AT SELECTION-SCREEN  ON from_ms.
  " verify that from_ms is numeric
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'from_ms' ).      "#EC NOTEXT

AT SELECTION-SCREEN  ON todate.
  " verify that end date is not before start date
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'todate' ).       "#EC NOTEXT
AT SELECTION-SCREEN  ON totime.
  " verify that end time is not before start time
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'totime' ).       "#EC NOTEXT
AT SELECTION-SCREEN  ON to_ms.
  " verify that to_ms is numeric
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'to_ms' ).        "#EC NOTEXT

AT SELECTION-SCREEN  ON client.
  " verify that client exists
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'client' ).       "#EC NOTEXT

AT SELECTION-SCREEN  ON user.
  " verify that user exists
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Check_Field_Value( 'user' ).         "#EC NOTEXT


AT SELECTION-SCREEN.
  IF ( command IS NOT INITIAL ).
    " report is called via SUBMIT REPORT and a command has been specified
    sy-ucomm = command.
    FREE command.
  ENDIF.
  CAST CL_PTC_V_SCREEN( Controller->Get_View( ) )->Raise_USER_COMMAND( sy-ucomm ).

" end of selection screen events

"=======================================================================
