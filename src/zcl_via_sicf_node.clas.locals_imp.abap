CLASS lcl_home_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.


CLASS lcl_home_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    io_context->ok( 'Welcome to VIA API - ABAP Minimal API Server' ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_hello_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.


CLASS lcl_hello_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    TYPES: BEGIN OF ty_s_greeting,
             message TYPE string,
             status  TYPE string,
           END OF ty_s_greeting.

    DATA(ls_resp) = VALUE ty_s_greeting( message = 'Hello World from ABAP Minimal API!'
                                         status  = 'success' ).
    io_context->ok( ls_resp ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_user_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.


CLASS lcl_user_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    TYPES: BEGIN OF ty_s_user,
             id   TYPE string,
             name TYPE string,
             role TYPE string,
           END OF ty_s_user.

    DATA(lv_id) = io_context->param( 'id' ).

    IF lv_id IS INITIAL.
      io_context->bad_request( 'User ID is required' ).
      RETURN.
    ENDIF.

    IF lv_id = '999'.
      io_context->not_found( |User with ID { lv_id } not found| ).
      RETURN.
    ENDIF.

    DATA(ls_user) = VALUE ty_s_user( id   = lv_id
                                     name = |User { lv_id }|
                                     role = 'Developer' ).
    io_context->ok( ls_user ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_create_user_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.


CLASS lcl_create_user_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    TYPES: BEGIN OF ty_s_user_create,
             name TYPE string,
             role TYPE string,
           END OF ty_s_user_create.

    DATA ls_input TYPE ty_s_user_create.

    io_context->bind( CHANGING cv_data = ls_input ).

    IF ls_input-name IS INITIAL.
      io_context->bad_request( 'Field "name" is required' ).
      RETURN.
    ENDIF.

    io_context->created( iv_data = ls_input
                         iv_uri  = '/users/101' ).
  ENDMETHOD.
ENDCLASS.
