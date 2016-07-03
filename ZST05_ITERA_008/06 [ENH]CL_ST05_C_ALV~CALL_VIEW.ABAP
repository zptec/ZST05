ENHANCEMENT 1  ZTMPTB_I03.    "active version
*ST05 GET SELECTION RESULT —— boris town
*SYSTEM VERSION: EHP7 FOR SAP ERP 6.0
*ENHANCEMENT-POINT CL_ST05_C_ALV=>CALL_VIEW
  IF SY-TCODE EQ 'ZST05'.
    DATA: ZTMPTB_DESCR_REF TYPE REF TO CL_ABAP_TYPEDESCR.
    ZTMPTB_DESCR_REF = CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( data ).
    IF STRUCTURE_NAME EQ 'ST05_RECORD_DISP'
      AND ZTMPTB_DESCR_REF->ABSOLUTE_NAME EQ '\TYPE=ST05_MAIN_RECORD_TABLE'.
      DATA LT_ZTMPTB_MAIN_RECORD TYPE TABLE OF ZTMPTB_MAIN_RECORD.
      "CALL TABLE RELATION ANALYZER
      CALL FUNCTION 'ZTMPTB_TABLE_RELATION'
       TABLES
         IT_MAIN_RECORD_OLD       = DATA[]
         ET_MAIN_RECORD_NEW       = LT_ZTMPTB_MAIN_RECORD[]
                .

**********************************
*COPIED FROM BELOW SOURCE CODE BEGIN
**********************************
"
" Call ztmptb_view to display data.
"
  DATA : ztmptb_view  TYPE REF TO cl_ST05_V_ALV.
  ztmptb_view = me->get_view( ).

  DATA : ztmptb_l_display_properties  TYPE ST05_DISPLAY_PROPERTIES.
  IF ( back = 'X' ).
    " the user has pushed the BACK button
    " ==> do not need to save the current display properties,
    "     but retrieve the previous display properties
    ztmptb_l_display_properties = me->Get_Previous_Display_Props( ) .
    " delete the current properties from the controller
    DELETE  me->display_properties_table
      INDEX lines( me->display_properties_table ).

  ELSE.
    " forward navigation
    " ==> get display properties for the current display type (from the ztmptb_view's ALV grid)
    "     and save them in the controller's display properties table for subsequent backward navigation
    ztmptb_l_display_properties = ztmptb_view->Get_Display_Properties( ).
    me->Set_Display_Properties( ztmptb_l_display_properties ).

    " build display properties for the subsequent display type
    FREE ztmptb_l_display_properties.
    ztmptb_l_display_properties-name                = display_properties-name.
    ztmptb_l_display_properties-record_number_table = display_properties-record_number_table.

    " append display properties for the subsequent display type to he controller's display properties table
    me->Append_Display_Properties( ztmptb_l_display_properties ).

  ENDIF.  " display_type = me->Get_Previous_Display_Type( )

  ztmptb_view->Set_Display_Properties( ztmptb_l_display_properties ).

  ztmptb_view->Show_Data( EXPORTING  structure_name   = 'ZTMPTB_RECORD_DISP'
                              display_property = ztmptb_l_display_properties
                   CHANGING   data           = LT_ZTMPTB_MAIN_RECORD ).
**********************************
*COPIED FROM BLOW SOURCE CODE END
**********************************
      RETURN.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
