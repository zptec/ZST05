MODULE  Start_0010  OUTPUT.

  CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'Trace Display' )->Get_View( ) )->Raise_Titlebar( ).                    "#EC NOTEXT
  CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'Trace Display' )->Get_View( ) )->Raise_Status( command = command ).    "#EC NOTEXT
  CAST CL_PTC_V_SCREEN( cl_PTC_MVC=>Get_Controller( 'Trace Display' )->Get_View( ) )->Raise_PBO( ).                         "#EC NOTEXT

ENDMODULE.  " Start_0010  OUTPUT
