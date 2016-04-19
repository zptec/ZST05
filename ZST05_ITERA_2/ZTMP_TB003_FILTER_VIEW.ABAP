CLASS lcl_ST05_Trace_Filter_V  DEFINITION
  FINAL
  INHERITING FROM cl_ST05_Trace_Filter_V.
"
" local view class for filter selection screen
"
  PUBLIC SECTION.
    METHODS :
      Customize_Selection_Screen  REDEFINITION,
      Call_Screen                 REDEFINITION,
      Set_Screen_Fields           REDEFINITION,
      Get_Screen_Fields           REDEFINITION,
      Check_Screen_Field_Value    REDEFINITION,
      Check_Field_Value           REDEFINITION.

  PRIVATE SECTION.
    DATA : user_range  TYPE ST05_USER_RANGE.

ENDCLASS.  " lcl_ST05_Trace_Filter_V  DEFINITION


CLASS lcl_ST05_Trace_Filter_V  IMPLEMENTATION.

  METHOD Call_Screen.
  " IMPORTING
  "   SCREEN_NUMBER	 TYPE SYDYNNR
  "
  " Call the selection screen.
  "
    CALL SELECTION-SCREEN 1000.

  ENDMETHOD.  " Call_Screen.


  METHOD Customize_Selection_Screen.
  "
  " Csutomize the selection screen's GUI status.
  "
    " Add custom buttons to selection screen.
    DATA : button  TYPE SMP_DYNTXT .
    button-TEXT = text-B1T.            " Display
    button-ICON_ID = icon_detail."'@10@'.
    button-QUICKINFO = text-B1Q.       " Display trace records
    sscrfields-functxt_01 = button.

    button-TEXT = text-B2T.            " Display
    button-ICON_ID = icon_summarize.
    button-QUICKINFO = text-B2Q.       " Display structure-identical trace records
    sscrfields-functxt_02 = button.

    button-TEXT = text-B3T.            " Display
    button-ICON_ID = icon_overview.
    button-QUICKINFO = text-B3Q.       " Display trace overview
    sscrfields-functxt_03 = button.

    button-TEXT = text-B4T.            " Save
    button-ICON_ID = '@PO@'.
    button-QUICKINFO = text-B4Q.       " Save trace records to DB
    sscrfields-functxt_04 = button.

    " Exclude standard functions from selection screen GUI status.
    DATA : command_table  TYPE TABLE OF sy-ucomm.
    APPEND 'SJOB'  TO command_table.

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING  p_status  = sy-pfkey
      TABLES     p_exclude = command_table.

  ENDMETHOD.  " Customize_Selection_Screen.


  METHOD Set_Screen_Fields.
  " IMPORTING
  "   trace_types   TYPE ST05_TRACE_TYPES
  "   trace_period  TYPE ST05_TRACE_PERIOD
  "
  " Set the values of globally defined variables used on the program's (selection) screen.
  "
    IF (     '' = p_SQL AND '' = p_BUF AND '' = p_ENQ AND '' = p_RFC AND '' = p_HTTP AND '' = p_APC AND '' = p_AMC
         AND '00000000' = fromdate AND '000000' = fromtime
         AND '00000000' = todate   AND '000000' = totime ).
      " None of the most relevant selection screen fields are prefilled.
      " trace type
      p_sql  = trace_types-SQL_on.
      p_buf  = trace_types-BUF_on.
      p_enq  = trace_types-ENQ_on.
      p_rfc  = trace_types-RFC_on.
      p_http = trace_types-HTTP_on.
      p_apc  = trace_types-APC_on.
      p_amc  = trace_types-AMC_on.

      " trace period
      fromdate = trace_period-user-start_date.
      fromtime = trace_period-user-start_time.
      from_ms  = trace_period-user-start_ms.
      todate   = trace_period-user-end_date.
      totime   = trace_period-user-end_time.
      to_ms    = trace_period-user-end_ms.
    ENDIF.

    " client
    IF (     client[] IS INITIAL
         AND 'X' <> cl_system_client_check=>is_system_client( ) ).
      " Current logon client is an application client.
      " ==> Display trace records from current logon client only.
      DATA : current_client TYPE C LENGTH 6.
      current_client = |IEQ| && |{ sy-mandt }|.
      APPEND current_client  TO client.
    ELSE.
      " Current logon client is system client.
      " ==> Trace records from all clients may be displayed.
      " NOP
    ENDIF.

    " Dynamic modification of screen field properties.
    LOOP AT SCREEN.
      IF ( screen-group1 = 'EXP' ).
        IF ( 'X' = me->Get_Expert_Mode( ) ).
          screen-invisible = 0.
        ELSE.
          screen-invisible = 1.
        ENDIF.  " 'X' = me->Get_Expert_Mode( )
        MODIFY SCREEN.
      ELSEIF ( screen-group1 = 'FIL'  OR  screen-group1 = 'DST'  OR  screen-group1 = 'ID' ).
        IF (    'X' = me->Get_Expert_Mode( ) ).
          screen-invisible = 0.
          screen-active    = 1.
        ELSE.
          screen-invisible = 1.
          screen-active    = 0.
        ENDIF.  " 'X' = me->Get_Expert_Mode( )
        MODIFY SCREEN.
      ELSEIF screen-group1 = 'CLI'.
        " Allow client selection only in system clients.
        IF ( 'X' <> cl_system_client_check=>is_system_client( ) ).
          " Current logon client is application client.
          " ==> Display trace records from current logon client only.
          "     ==> Set the client field to not modifiable.
          screen-input = 0.
          MODIFY SCREEN.
        ENDIF.
      ELSEIF screen-group1 = 'NO'.
        " Never show the command parameter.
        screen-invisible = 1.
        screen-active    = 0.
        MODIFY SCREEN.
      ENDIF.  " screen-group1 = 'EXP'
      IF ( screen-group1 = 'SQL' ).
        IF (     'X' = me->Get_SQLMonitor_Mode( )  OR  'SQLM' = command
             OR  ( program IS NOT INITIAL  AND  include IS NOT INITIAL  AND  line IS NOT INITIAL ) ).
          screen-invisible = 0.
          screen-active    = 1.
        ELSE.
          screen-invisible = 1.
          screen-active    = 0.
        ENDIF.  " 'X' = me->Get_SQLMonitor_Mode( )
        MODIFY SCREEN.
      ENDIF.  " screen-group1 = 'SQL'
    ENDLOOP.  " AT SCREEN

  ENDMETHOD.  " Set_Screen_Fields.


  METHOD Get_Screen_Fields.
  " EXPORTING
  "   trace_types   TYPE ST05_TRACE_TYPES
  "   trace_period  TYPE ST05_TRACE_PERIOD
  "   user_range              TYPE ST05_USER_RANGE
  "   client_range            TYPE ST05_CLIENT_RANGE
  "   object_range            TYPE ST05_OBJECT_RANGE
  "   duration_range          TYPE ST05_DURATION_RANGE
  "   operation_range         TYPE ST05_OPERATION_RANGE
  "   DB_connection_range     TYPE ST05_CONNECTION_RANGE
  "   DB_connection_ID_range  TYPE ST05_CONNECTION_ID_RANGE
  "   WP_ID_range             TYPE ST05_WP_ID_RANGE
  "   trans_ID_range          TYPE ST05_TRANS_ID_RANGE
  "   EPP_root_ID_range       TYPE ST05_EPP_ROOT_ID_RANGE
  "   EPP_conn_ID_range       TYPE ST05_EPP_CONN_ID_RANGE
  "   EPP_conn_cnt_range      TYPE ST05_EPP_CONN_CNT_RANGE
  "   maximum_number_of_records  TYPE ST05_TRACE_RECORD_NUMBER
  "   continuation_popup_flag    TYPE BOOLEAN
  "   progress_indicator_flag    TYPE BOOLEAN
  "   GUID                       TYPE SYSUUID_X16
  "   PROGRAM_NAME               TYPE PTC_PROGRAM_NAME
  "   INCLUDE_NAME               TYPE PTC_INCLUDE_NAME
  "   LINE_NUMBER	               TYPE	PTC_LINE_NUMBER
  "
  " Get the values of globally defined variables used on the program's (selection) screen.
  "
    " Initialize.
    FREE : trace_types,
           trace_period.

    " trace types
    trace_types-SQL_on  = p_sql.
    trace_types-BUF_on  = p_buf.
    trace_types-ENQ_on  = p_enq.
    trace_types-RFC_on  = p_rfc.
    trace_types-HTTP_on = p_http.
    trace_types-APC_on  = p_apc.
    trace_types-AMC_on  = p_amc.

    " trace period
    trace_period-user-start_date = fromdate.
    trace_period-user-start_time = fromtime.
    trace_period-user-start_ms   = from_ms.
    trace_period-user-end_date   = todate.
    trace_period-user-end_time   = totime.
    trace_period-user-end_ms     = to_ms.

    " ranges tables
    user_range             = user[].
    client_range           = client[].
    object_range           = object[].
    duration_range         = duration[].
    operation_range        = operatio[].
    DB_connection_range    = con_name[].
    DB_connection_ID_range = con_ID[].
    WP_ID_range            = WP_ID[].
    trans_ID_range         = trans_ID[].
    EPP_root_ID_range      = root_ID[].
    EPP_conn_ID_range      = conn_ID[].
    EPP_conn_cnt_range     = conn_cnt[].

    " miscellaneous parameters
    maximum_number_of_records = max_rec.
    continuation_popup_flag   = popup.
    progress_indicator_flag   = progress.

    " GUID of a trace previously persisted to DB
    GUID = p_GUID.

    " program, include, line number
    program_name = program.
    include_name = include.
    line_number  = line.

  ENDMETHOD.  " Get_Screen_Fields.


  METHOD Check_Field_Value.
  " IMPORTING
  "   field_name  TYPE STRING
  "
  " Check validity of value entered in screen field.
  "
    CASE  field_name.
      WHEN  'fromdate'.
        " Verify that start date is not in the future.
        IF ( SY-DATLO < fromdate ).
          MESSAGE E020  WITH fromdate.
        ENDIF.
      WHEN  'fromtime'.
        " Verify that start time is not in the future.
        IF ( SY-DATLO = fromdate  AND  SY-TIMLO < fromtime ).
          MESSAGE E021  WITH fromtime.
        ENDIF.
      WHEN  'from_ms'.
        " Verify that from_ms is numeric.
        IF ( contains_any_not_of( val = from_ms  sub = '0123456789' ) ).
          MESSAGE E024.
        ENDIF.

      WHEN  'todate'.
        " Verify that end date is not before start date.
        IF ( todate < fromdate ).
          MESSAGE E022  WITH todate fromdate.
        ENDIF.
      WHEN  'totime'.
        " Verify that end time is not before start time.
        IF ( todate = fromdate  AND  totime < fromtime ).
          MESSAGE E023  WITH todate fromdate.
        ENDIF.
      WHEN  'to_ms'.
        " Verify that to_ms is numeric.
        IF ( contains_any_not_of( val = to_ms  sub = '0123456789' ) ).
          MESSAGE E024.
        ENDIF.

      WHEN  'client'.
        " Verify that client exists.
        IF ( ' ' =  cl_ST05_Utilities=>Check_Client( client-low ) ).
            MESSAGE E040  WITH client-low SY-SYSID.
            " Client & does not exist in system &.
        ENDIF.

      WHEN  'user'.
        IF ( 1 <> lines( user[] ) ).
          " Ranges table for user contains multiple rows or no row at all.
          " ==> Use as is.
        ELSE.
          " Ranges table for user contains exactly one row.
          me->user_range = user[].
          FIELD-SYMBOLS : <user_selection>  TYPE ST05_USER_SEL.
          READ TABLE  me->user_range
            INDEX  1
            ASSIGNING  <user_selection>.
          IF (     <user_selection>-low CA '*+'
               OR  <user_selection>-high <> '' ).
            " Ranges table for user contains row with wildcard(s) or interval.
            " ==> Use as is.
            FREE  me->user_range.
          ELSE.
            " Ranges table for user contains one simple row.
            DATA : user_name     TYPE SYUNAME,
                   check_result  TYPE  C  LENGTH 1.
            cl_ST05_Utilities=>Check_User( EXPORTING in_user = <user_selection>-low
                                                     client  = client-low
                                           IMPORTING out_user     = user_name
                                                     check_result = check_result ).
            CASE check_result.
              WHEN  '0'.
                IF ( '*' = client-low  OR  '' = client-low ).
                  " User & does not exist in system &
                  MESSAGE E030  WITH <user_selection>-low SY-SYSID.
                ELSE.
                  " User & does not exist in client &
                  MESSAGE E031  WITH <user_selection>-low client-low.
                ENDIF.
              WHEN  '1'.
                IF ( '*' = client-low  OR  '' = client-low ).
*                  " User & is locked in at least one client of system &
*                  MESSAGE W032  WITH <user_selection>-low SY-SYSID.
                ELSE.
                  " User & is locked in client &
                  MESSAGE W033  WITH <user_selection>-low client-low.
                ENDIF.
              WHEN  '2'.
                " & is a front end alias for back end user &
                MESSAGE S034  WITH <user_selection>-low user_name.
                <user_selection>-low = user_name.
              WHEN  '3'.
                " & is a front end alias for locked back end user &
                MESSAGE W035  WITH <user_selection>-low user_name.
              WHEN  '4'.
                " & is a front end alias for multiple back end users in system &
                MESSAGE E036  WITH <user_selection>-low SY-SYSID.
            ENDCASE.
          ENDIF.
        ENDIF.  " 1 <> lines( user )

    ENDCASE.  "  field_name.

  ENDMETHOD.  " Check_Field_Value.


  METHOD Check_Screen_Field_Value.
  " IMPORTING
  "   field_name  TYPE STRING
  " RETURNING
  "   value_is_valid  TYPE ST05_BOOLEAN
    "
    " Check screen field value.
    "
    FIELD-SYMBOLS : <field_value>  TYPE ANY.
    ASSIGN (field_name)  TO <field_value>.

    IF ( field_name = 'from_ms'  OR field_name = 'to_ms' ).
      IF ( contains_any_not_of( val = <field_value>  sub = '0123456789' ) ).
        MESSAGE E024.
      ENDIF.
    ENDIF.

    IF ( field_name = 'user[]' ).
      FIELD-SYMBOLS : <user_range>  TYPE ST05_USER_RANGE.
      ASSIGN (field_name)  TO <user_range>.
      IF ( 1 <> lines( <user_range> ) ).
        " Ranges table for user contains multiple rows or no row at all.
        " ==> Use as is.
      ELSE.
        me->user_range = <user_range>.
        FIELD-SYMBOLS : <user_selection>  TYPE ST05_USER_SEL.
        READ TABLE  me->user_range
          INDEX  1
          ASSIGNING  <user_selection>.
        IF (     <user_selection>-low CA '*+'
             OR  <user_selection>-high <> '' ).
          " Ranges table for user contains row with wildcard(s) or interval.
          " ==> Use as is.
          FREE  me->user_range.
        ELSE.
          " Ranges table for user contains one simple row.
          DATA : "user_name     TYPE SYUNAME,
                 check_result  TYPE  C  LENGTH 1.
          cl_ST05_Utilities=>Check_User( EXPORTING in_user = <user_selection>-low
                                                   client  = client-low
                                         IMPORTING "out_user     = user_name
                                                   check_result = check_result ).
          CASE check_result.
            WHEN  '0'.
              MESSAGE E030  WITH <user_selection>-low client-low.
          ENDCASE.
        ENDIF.
      ENDIF.  "  1 <> lines( <user_range> )
    ENDIF.  " field_name = 'user'

    IF ( field_name = 'client' ).
      FIELD-SYMBOLS : <client>  TYPE SYMANDT.
      ASSIGN COMPONENT 'LOW'  OF STRUCTURE <field_value>  TO <client>.
      IF ( ' ' =  cl_ST05_Utilities=>Check_Client( <client> ) ).
          MESSAGE E040  WITH <client> SY-SYSID.
          " Client & does not exist in system &
      ENDIF.
    ENDIF.  " field_name = 'client'

  ENDMETHOD.  " Check_Screen_Field_Value.

ENDCLASS.  " lcl_ST05_Trace_Filter_V  IMPLEMENTATION.
