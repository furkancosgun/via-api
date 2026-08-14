CLASS zcl_via_error_handler DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_via_error_handler.
ENDCLASS.


CLASS zcl_via_error_handler IMPLEMENTATION.
  METHOD zif_via_error_handler~handle.
    DATA(lo_error)  = COND #( WHEN ix_error IS INSTANCE OF zcx_via_error
                              THEN CAST zcx_via_error( ix_error ) ).

    DATA(lv_status) = COND i( WHEN lo_error IS BOUND
                              THEN lo_error->get_status( )
                              ELSE 500 ).

    DATA(lv_json)   = COND string( WHEN lo_error IS BOUND
                                   THEN |\{"type":"{ lo_error->get_type( ) }","title":"{ lo_error->get_title( ) }",| &&
                                        |"status":{ lv_status },"detail":"{ lo_error->get_detail( ) }",| &&
                                        |"instance":"{ lo_error->get_instance( ) }"\}|
                                   ELSE |\{"type":"about:blank","title":"Internal Server Error",| &&
                                        |"status":500,"detail":"{ ix_error->get_text( ) }"\}| ).

    IF lo_error IS BOUND AND lv_status = 405.
      io_context->header( iv_name  = 'Allow'
                          iv_value = lo_error->get_allow( ) ).
    ENDIF.

    TRY.
        io_context->status( lv_status )->header( iv_name  = 'content-type'
                                                 iv_value = 'application/problem+json' )->text( lv_json ).
      CATCH zcx_via_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
