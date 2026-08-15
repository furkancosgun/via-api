CLASS zcl_via_example_router DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Registers sample CRUD routes on the provided server instance
    "! @parameter io_server | VIA API server instance
    METHODS register_routes
      IMPORTING io_server TYPE REF TO zif_via_server.
ENDCLASS.


CLASS zcl_via_example_router IMPLEMENTATION.
  METHOD register_routes.
    io_server->get( iv_path    = '/api/v1/users'
                    io_handler = NEW lcl_get_users_handler( ) ).

    io_server->get( iv_path    = '/api/v1/users/{id}'
                    io_handler = NEW lcl_get_user_by_id_handler( ) ).

    io_server->post( iv_path    = '/api/v1/users'
                     io_handler = NEW lcl_create_user_handler( ) ).

    io_server->delete( iv_path    = '/api/v1/users/{id}'
                       io_handler = NEW lcl_delete_user_handler( ) ).

    io_server->all( iv_path    = '/api/v1/health'
                    io_handler = NEW lcl_health_handler( ) ).
  ENDMETHOD.
ENDCLASS.
