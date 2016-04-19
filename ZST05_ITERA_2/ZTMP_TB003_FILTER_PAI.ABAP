MODULE  Process_User_Command INPUT.

  IF ( command IS NOT INITIAL ).
    CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'Trace Display' )->Get_View( ) )->Raise_User_Command( command ).      "#EC NOTEXT
    IF ( 'FIND' <> command  AND  'FIND_NEXT' <> command ).
      FREE command.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.  " command IS NOT INITIAL

ENDMODULE.  " Process_User_Command INPUT


MODULE  Process_Exit_Command INPUT.  " AT EXIT-COMMAND

  CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'Trace Display' )->Get_View( ) )->Raise_Exit_Command( ).                "#EC NOTEXT

ENDMODULE.  " Process_Exit_Command INPUT
