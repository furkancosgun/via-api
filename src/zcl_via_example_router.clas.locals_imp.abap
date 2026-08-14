TYPES:
  BEGIN OF ty_s_user_dto,
    id   TYPE string,
    name TYPE string,
    role TYPE string,
  END OF ty_s_user_dto.

TYPES ty_t_user_dto TYPE STANDARD TABLE OF ty_s_user_dto WITH EMPTY KEY.


CLASS lcl_get_users_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.

CLASS lcl_get_users_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    DATA lt_users TYPE ty_t_user_dto.

    lt_users = VALUE #( ( id = '101' name = 'Furkan' role = 'Admin' )
                        ( id = '102' name = 'Ali'    role = 'Developer' ) ).

    io_context->ok( lt_users ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_get_user_by_id_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.

CLASS lcl_get_user_by_id_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    DATA(lv_id) = io_context->param( 'id' ).

    IF lv_id = '999'.
      io_context->not_found( 'User with specified ID does not exist' ).
      RETURN.
    ENDIF.

    io_context->ok( VALUE ty_s_user_dto( id = lv_id name = 'Furkan' role = 'Admin' ) ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_create_user_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.

CLASS lcl_create_user_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    DATA ls_user TYPE ty_s_user_dto.

    io_context->bind( CHANGING cv_data = ls_user ).

    IF ls_user-name IS INITIAL.
      io_context->bad_request( 'User name is required' ).
      RETURN.
    ENDIF.

    ls_user-id = '103'.
    io_context->created( iv_uri  = |/api/v1/users/{ ls_user-id }|
                         iv_data = ls_user ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_delete_user_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.

CLASS lcl_delete_user_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    DATA(lv_id) = io_context->param( 'id' ).

    IF lv_id IS INITIAL.
      io_context->bad_request( 'User ID is required' ).
      RETURN.
    ENDIF.

    io_context->no_content( ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_health_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.

CLASS lcl_health_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    io_context->ok( VALUE ty_s_user_dto( id   = 'ok'
                                         name = io_context->method( )
                                         role = 'Healthy' ) ).
  ENDMETHOD.
ENDCLASS.
