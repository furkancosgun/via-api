CLASS zcl_via_sicf_node DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.


CLASS zcl_via_sicf_node IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA(lo_app) = zcl_via_server=>factory_onprem( server ).

    NEW zcl_via_example_router( )->register_routes( lo_app ).

    lo_app->dispatch( ).
  ENDMETHOD.
ENDCLASS.
