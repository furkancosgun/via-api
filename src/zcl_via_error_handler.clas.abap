CLASS zcl_via_error_handler DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_via_error_handler.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_problem,
        type     TYPE string,
        title    TYPE string,
        status   TYPE i,
        detail   TYPE string,
        instance TYPE string,
      END OF ty_s_problem.

ENDCLASS.


CLASS zcl_via_error_handler IMPLEMENTATION.
  METHOD zif_via_error_handler~handle.
    DATA lo_json TYPE REF TO zif_via_serializer.
    DATA lv_json TYPE string.

    DATA(lo_error) = COND #( WHEN ix_error IS INSTANCE OF zcx_via_error
                             THEN CAST zcx_via_error( ix_error ) ).

    DATA(lv_status) = COND i( WHEN lo_error IS BOUND
                              THEN lo_error->get_status( )
                              ELSE 500 ).

    DATA(ls_problem) = VALUE ty_s_problem( status = lv_status ).
    IF lo_error IS BOUND.
      ls_problem-type     = lo_error->get_type( ).
      ls_problem-title    = lo_error->get_title( ).
      ls_problem-detail   = lo_error->get_detail( ).
      ls_problem-instance = lo_error->get_instance( ).
    ELSE.
      ls_problem-type   = 'about:blank'.
      ls_problem-title  = 'Internal Server Error'.
      ls_problem-detail = ix_error->get_text( ).
    ENDIF.

    IF lo_error IS BOUND AND lv_status = 405.
      io_context->header( iv_name  = 'Allow'
                          iv_value = lo_error->get_allow( ) ).
    ENDIF.

    lo_json = NEW zcl_via_serializer_json( ).
    TRY.
        lv_json = lo_json->serialize( ls_problem ).
      CATCH zcx_via_error INTO DATA(lx_serialize).
        io_context->status( 500 )->text( lx_serialize->get_text( ) ).
        RETURN.
    ENDTRY.

    io_context->status( lv_status )->text( lv_json )->header( iv_name  = 'content-type'
                                                              iv_value = 'application/problem+json' ).
  ENDMETHOD.
ENDCLASS.
