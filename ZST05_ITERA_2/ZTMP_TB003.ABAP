"COPYED FROM R_ST05_TRACE_FILTER
REPORT  R_ST05_Trace_Filter  NO STANDARD PAGE HEADING
                             MESSAGE-ID ST05.
"
" Get filter conditions for trace records to be displayed.
" Display trace records that pass the filter conditions.
"

"=======================================================================

INCLUDE ZTMP_TB003_FILTER_TOP.
*  INCLUDE  R_ST05_TRACE_FILTER_TOP.              " global variables

"=======================================================================

  " declaration and definition of global data
  LOAD-OF-PROGRAM.
    " Check for authorization to display ST05 traces.
      IF ( ' ' = cl_PTC_UTILITIES=>Authority_Check( object = 'S_ADMI_FCD'
                                                    field  = 'S_ADMI_FCD'
                                                    value  = 'ST0R' ) ).
        MESSAGE text-M01  TYPE 'A'.    " = You do not have sufficient authorizations to start transaction STATS.
      ENDIF.
    TRY.
      cl_PTC_MVC=>Create( model_class_name      = '\CLASS=CL_ST05_TRACE_FILTER_M'
                          view_class_name       = '\PROGRAM=R_ST05_TRACE_FILTER\CLASS=LCL_ST05_TRACE_FILTER_V'
                          controller_class_name = '\CLASS=CL_ST05_TRACE_FILTER_C'
                          MVC_name              = 'Trace Record Filter' ).     "#EC NOTEXT

      DATA(Controller) = CAST cl_ST05_TRACE_FILTER_C( cl_PTC_MVC=>Get_Controller( 'Trace Record Filter' ) ). "#EC NOTEXT

    CATCH CX_PTC INTO DATA(exception).
      DATA(exception_text) = condense( exception->Get_Text( ) ).
      MESSAGE exception_text  TYPE 'A'.
    ENDTRY.

  " end of  LOAD-OF-PROGRAM.

"=======================================================================

INCLUDE ZTMP_TB003_FILTER_SEL_SCR.
*  INCLUDE  R_ST05_TRACE_FILTER_SEL_SCR.          " definition of selection screen
                                                 " (layout and event handling)
INCLUDE ZTMP_TB003_FILTER_VIEW.
*  INCLUDE  R_ST05_TRACE_FILTER_VIEW.             " local view class for filter selection screen
INCLUDE ZTMP_TB003_DISPLAY_VIEW.
*  INCLUDE  R_ST05_TRACE_DISPLAY_VIEW.            " local view class for trace display screen

INCLUDE ZTMP_TB003_FILTER_PBO.
*  INCLUDE R_ST05_TRACE_FILTER_PBO.               " PBO modules for trace display screen
INCLUDE ZTMP_TB003_FILTER_PAI.
*  INCLUDE R_ST05_TRACE_FILTER_PAI.               " PAI modules for trace display screen

"=======================================================================

  " implicit unique initialization of selection screen fields
  INITIALIZATION.
    " NOP
    " (Initialization is done explicitly and for each call of the
    "  selection screen in event AT SELECTION-SCREEN OUTPUT.)

  " end of  INITIALIZATION.

"=======================================================================

  " main program
  START-OF-SELECTION.

    IF ( Controller IS BOUND ).
*      DO.                                          " this DO loop is required for independet selection screens
*        Controller->Run( '1000' ).
*        IF ( Controller IS NOT BOUND ).
*          EXIT.  " DO loop
*        ENDIF.
*      ENDDO.
*      LEAVE PROGRAM.
      RETURN.
    ELSE.
      RETURN.
    ENDIF.  " Controller  IS  BOUND

  " end of  START-OF-SELECTION.

"=======================================================================

  END-OF-SELECTION.
    " NOP (no logical DB)

  " end of  END-OF-SELECTION.

"=======================================================================


  AT USER-COMMAND.   " for interaction on DDIC information and application component hierarchy display
    TRY.
      CASE SY-UCOMM.
        WHEN  'LEVEL0'  OR  'LEVEL1'.
          CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'Trace Display' )->Get_View( ) )->Raise_USER_COMMAND( sy-ucomm ).  "#EC NOTEXT
        WHEN OTHERS.
          CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'DDIC Info' )->Get_View( ) )->Raise_USER_COMMAND( sy-ucomm ).      "#EC NOTEXT
      ENDCASE.  " SY-UCOMM
    CATCH CX_PTC.                                     "#EC NO_HANDLER
    ENDTRY.

" end of REPORT  R_ST05_Trace_Filter.
