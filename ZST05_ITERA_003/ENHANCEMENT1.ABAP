ENHANCEMENT 1  ZTMPTB_I03.    "active version
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(2) Class CL_PTC_C_ALV, Method CALL_VIEW, Start, Enhancement ZTMPTB_I03, Start                                                                        A
*ST05 APPENDING FIELD —— boris town
*SYSTEM VERSION: EHP3 FOR SAP CRM 7.0
*ENHANCEMENT-POINT CL_PTC_C_ALV=>CALL_VIEW
  IF SY-UNAME EQ 'HANDTB'.
    IF STRUCTURE_NAME EQ 'ST05_RECORD_DISP'.
      DATA LT_ZTMPTB_MAIN_RECORD TYPE TABLE OF ZTMPTB_MAIN_RECORD.
      DATA LS_ZTMPTB_MAIN_RECORD TYPE ZTMPTB_MAIN_RECORD.
      DATA LT_ZTMPTB_MAIN_RECORD_OLD TYPE TABLE OF ST05_MAIN_RECORD.
      DATA LS_ZTMPTB_MAIN_RECORD_OLD TYPE ST05_MAIN_RECORD.
*      FIELD-SYMBOLS <FS_ZTMPTB_DATATAB> TYPE ANY TABLE.
*      DATA L_ZTMPTB_DATATAB_NAME TYPE CHAR30.
      CLEAR LT_ZTMPTB_MAIN_RECORD[].
      CLEAR LT_ZTMPTB_MAIN_RECORD_OLD[].
      LT_ZTMPTB_MAIN_RECORD_OLD = DATA.
      LOOP AT LT_ZTMPTB_MAIN_RECORD_OLD INTO LS_ZTMPTB_MAIN_RECORD_OLD.
        MOVE-CORRESPONDING LS_ZTMPTB_MAIN_RECORD_OLD TO LS_ZTMPTB_MAIN_RECORD.
        IF LS_ZTMPTB_MAIN_RECORD-STATEMENT_WITH_VALUES CP 'SELECT*'.
          LS_ZTMPTB_MAIN_RECORD-ZZREMARK01 = 'X'.
        ENDIF.
        APPEND LS_ZTMPTB_MAIN_RECORD TO LT_ZTMPTB_MAIN_RECORD.
        CLEAR LS_ZTMPTB_MAIN_RECORD.
      ENDLOOP.

**********************************
*COPIED FROM BLOW SOURCE CODE BEGIN
**********************************

" Call view to display data.
"
  DATA(ztmptb_view) = CAST CL_PTC_V_ALV( me->Get_View( ) ).

  DATA : ztmptb_l_display_properties  TYPE PTC_DISPLAY_PROPERTIES.
  IF ( back = 'X' ).
    " the user has pushed the BACK button
    " ==> do not need to save the current display properties,
    "     but retrieve the previous display properties
    ztmptb_l_display_properties = me->Get_Display_Properties( 1 ) .
    " delete the current properties from the controller
    DELETE  me->display_properties_table
      INDEX lines( me->display_properties_table ).

  ELSE.
    " forward navigation
    " ==> get display properties for the current display type (from the view's ALV grid)
    "     and save them in the controller's display properties table for subsequent backward navigation
    ztmptb_l_display_properties = ztmptb_view->Get_Display_Properties( ).
    me->Set_Display_Properties( ztmptb_l_display_properties ).

    " build display properties for the subsequent display type
    FREE ztmptb_l_display_properties.
    ztmptb_l_display_properties-name                    = display_properties-name.
    ztmptb_l_display_properties-variant-variant-variant = display_properties-variant-variant-variant.
    ztmptb_l_display_properties-record_number_table     = display_properties-record_number_table.

    " append display properties for the subsequent display type to he controller's display properties table
    me->Append_Display_Properties( ztmptb_l_display_properties ).

  ENDIF.  " display_type = me->Get_Previous_Display_Type( )

  ztmptb_view->Set_Display_Properties( ztmptb_l_display_properties ).

  CAST CL_PTC_V_ALV( me->Get_View( ) )->Show_Data( EXPORTING  structure_name   = 'ZTMPTB_RECORD_DISP'
                                                              display_property = ztmptb_l_display_properties
                                                   CHANGING   data           = LT_ZTMPTB_MAIN_RECORD ).
**********************************
*COPIED FROM BLOW SOURCE CODE END
**********************************
      BREAK-POINT.
      RETURN.
    ENDIF.
  ENDIF.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(3) Class CL_PTC_C_ALV, Method CALL_VIEW, Start, Enhancement ZTMPTB_I03, End                                                                          A
ENDENHANCEMENT.
