CLASS lcl_ST05_Trace_Display_V_S  DEFINITION
  FINAL
  INHERITING FROM cl_ST05_Trace_Display_V_S.
"
" local view class for trace display screen
"
  PUBLIC SECTION.
    METHODS :
      Free_View          REDEFINITION,
      Call_Screen        REDEFINITION,
      Check_Field_Value  REDEFINITION.

  PROTECTED SECTION.
    METHODS :
      Initialize_View    REDEFINITION.

ENDCLASS.  " lcl_ST05_Trace_Display_V_S  DEFINITION



CLASS lcl_ST05_Trace_Display_V_S  IMPLEMENTATION.

  METHOD  Initialize_View.
  "
  " (Re)Set object of class lcl_ST05_Trace_Display_V_S to its initial state.
  "
    " This method is not used in this class, but needs to be implemented.
    " Otherwise this class would be abstract.
    RETURN.

  ENDMETHOD.  " Initialize_View.


  METHOD  Free_View.
  "
  " Free object of class lcl_ST05_Trace_Display_V_S.
  "
    " This method is not used in this class, but needs to be implemented.
    " Otherwise this class would be abstract.
    RETURN.

  ENDMETHOD.  " Free_View.


  METHOD Call_Screen.
  " IMPORTING
  "   SCREEN_NUMBER	 TYPE SYDYNNR
  "
  " Call the screen with the specified number.
  "
    IF ( screen_number <> '0000' ).
      CALL SCREEN screen_number.
    ELSE.
      FREE command.
      LEAVE TO SCREEN screen_number.
    ENDIF.

  ENDMETHOD.  " Call_Screen.


  METHOD Check_Field_Value.
  " IMPORTING
  "   field_name  TYPE STRING
  "
  " Check validity of value entered in screen field.
  "
    " This method is not used in this class, but needs to be implemented.
    " Oherwise this class would be abstract.
    RETURN.
  ENDMETHOD.  " Check_Field_Value.

ENDCLASS.  " lcl_ST05_Trace_Display_V_S  IMPLEMENTATION.
