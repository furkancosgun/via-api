CLASS zcl_via_server DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! Creates a server instance for Cloud environment
    "! @parameter io_request  | HTTP request object
    "! @parameter io_response | HTTP response object
    "! @parameter ro_server   | Server instance
    CLASS-METHODS factory_cloud
      IMPORTING io_request       TYPE REF TO object
                io_response      TYPE REF TO object
      RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

    "! Creates a server instance for On-Premise environment
    "! @parameter io_server | ICF server object
    "! @parameter ro_server | Server instance
    CLASS-METHODS factory_onprem
      IMPORTING io_server        TYPE REF TO object
      RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

    "! Initializes server with HTTP handler
    "! @parameter io_http | HTTP abstraction instance
    METHODS constructor
      IMPORTING io_http TYPE REF TO zif_via_http.

    INTERFACES zif_via_server.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_route,
        path    TYPE string,
        method  TYPE string,
        handler TYPE REF TO zif_via_handler,
      END OF ty_s_route.
    TYPES ty_t_routes TYPE SORTED TABLE OF ty_s_route WITH UNIQUE KEY path method.

    TYPES:
      BEGIN OF ty_s_context,
        http          TYPE REF TO zif_via_http,
        cache         TYPE REF TO zif_via_cache,
        container     TYPE REF TO zif_via_container,
        serializer    TYPE REF TO zif_via_serializer,
        error_handler TYPE REF TO zif_via_error_handler,
        routes        TYPE ty_t_routes,
        middlewares   TYPE STANDARD TABLE OF REF TO zif_via_middleware WITH EMPTY KEY,
      END OF ty_s_context.

    DATA ms_context TYPE ty_s_context.

    METHODS add_route
      IMPORTING iv_path    TYPE string
                iv_method  TYPE string
                io_handler TYPE REF TO zif_via_handler.

    METHODS create_context
      IMPORTING it_parameters     TYPE zif_via_context=>ty_t_name_value
      RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

    METHODS match_route
      IMPORTING iv_path            TYPE string
                iv_method          TYPE string
      EXPORTING eo_route           TYPE REF TO zif_via_handler
                et_parameters      TYPE zif_via_context=>ty_t_name_value
                et_allowed_methods TYPE string_table.
ENDCLASS.


CLASS zcl_via_server IMPLEMENTATION.
  METHOD add_route.
    INSERT VALUE #( path    = iv_path
                    method  = iv_method
                    handler = io_handler )
           INTO TABLE ms_context-routes.
  ENDMETHOD.

  METHOD constructor.
    ms_context = VALUE ty_s_context( http          = io_http
                                     cache         = NEW zcl_via_cache( )
                                     container     = NEW zcl_via_container( )
                                     serializer    = NEW zcl_via_serializer_json( )
                                     error_handler = NEW zcl_via_error_handler( ) ).
  ENDMETHOD.

  METHOD factory_cloud.
    ro_server = NEW zcl_via_server( NEW lcl_cloud_service( io_request  = io_request
                                                           io_response = io_response ) ).
  ENDMETHOD.

  METHOD factory_onprem.
    FIELD-SYMBOLS <fs_request>  TYPE REF TO object.
    FIELD-SYMBOLS <fs_response> TYPE REF TO object.

    ASSIGN io_server->('REQUEST') TO <fs_request>.
    ASSERT sy-subrc = 0.
    ASSIGN io_server->('RESPONSE') TO <fs_response>.
    ASSERT sy-subrc = 0.

    ro_server = NEW zcl_via_server( NEW lcl_onprem_service( io_request  = <fs_request>
                                                            io_response = <fs_response> ) ).
  ENDMETHOD.

  METHOD zif_via_server~delete.
    add_route( iv_path    = iv_path
               iv_method  = 'DELETE'
               io_handler = io_handler ).
  ENDMETHOD.

  METHOD zif_via_server~get.
    add_route( iv_path    = iv_path
               iv_method  = 'GET'
               io_handler = io_handler ).
  ENDMETHOD.

  METHOD zif_via_server~options.
    add_route( iv_path    = iv_path
               iv_method  = 'OPTIONS'
               io_handler = io_handler ).
  ENDMETHOD.

  METHOD zif_via_server~patch.
    add_route( iv_path    = iv_path
               iv_method  = 'PATCH'
               io_handler = io_handler ).
  ENDMETHOD.

  METHOD zif_via_server~post.
    add_route( iv_path    = iv_path
               iv_method  = 'POST'
               io_handler = io_handler ).
  ENDMETHOD.

  METHOD zif_via_server~put.
    add_route( iv_path    = iv_path
               iv_method  = 'PUT'
               io_handler = io_handler ).
  ENDMETHOD.

  METHOD zif_via_server~all.
    zif_via_server~get( iv_path    = iv_path
                        io_handler = io_handler ).
    zif_via_server~post( iv_path    = iv_path
                         io_handler = io_handler ).
    zif_via_server~put( iv_path    = iv_path
                        io_handler = io_handler ).
    zif_via_server~delete( iv_path    = iv_path
                           io_handler = io_handler ).
    zif_via_server~patch( iv_path    = iv_path
                          io_handler = io_handler ).
    zif_via_server~options( iv_path    = iv_path
                            io_handler = io_handler ).
    ro_server = me.
  ENDMETHOD.

  METHOD create_context.
    ro_context = NEW zcl_via_context( io_http       = ms_context-http
                                      io_cache      = ms_context-cache
                                      io_container  = ms_context-container
                                      io_serializer = ms_context-serializer
                                      it_parameters = it_parameters ).
  ENDMETHOD.

  METHOD zif_via_server~dispatch.
    DATA lo_route           TYPE REF TO zif_via_handler.
    DATA lt_parameters      TYPE zif_via_context=>ty_t_name_value.
    DATA lt_allowed_methods TYPE string_table.
    DATA lv_allow           TYPE string.

    DATA(lv_path)   = ms_context-http->get_path( ).
    DATA(lv_method) = ms_context-http->get_method( ).

    match_route( EXPORTING iv_path            = lv_path
                           iv_method          = lv_method
                 IMPORTING eo_route           = lo_route
                           et_parameters      = lt_parameters
                           et_allowed_methods = lt_allowed_methods ).

    DATA(lo_context) = create_context( lt_parameters ).

    TRY.
        IF lo_route IS NOT BOUND.
          IF lt_allowed_methods IS INITIAL.
            zcx_via_error=>raise_not_found( iv_detail   = |No route for { lv_method } { lv_path }|
                                            iv_instance = lv_path ).
          ELSE.
            lv_allow = concat_lines_of( table = lt_allowed_methods
                                        sep   = `, ` ).
            zcx_via_error=>raise_method_not_allowed( iv_allowed  = lv_allow
                                                     iv_detail   = |{ lv_method } not allowed on { lv_path }|
                                                     iv_instance = lv_path ).
          ENDIF.
        ENDIF.

        LOOP AT ms_context-middlewares ASSIGNING FIELD-SYMBOL(<fs_middleware_before>).
          IF NOT <fs_middleware_before>->before( lo_context ).
            RETURN.
          ENDIF.
        ENDLOOP.

        lo_route->handle( lo_context ).

        LOOP AT ms_context-middlewares ASSIGNING FIELD-SYMBOL(<fs_middleware_after>).
          <fs_middleware_after>->after( lo_context ).
        ENDLOOP.
      CATCH cx_root INTO DATA(lx_error).
        ms_context-error_handler->handle( ix_error   = lx_error
                                          io_context = lo_context ).

        LOOP AT ms_context-middlewares ASSIGNING FIELD-SYMBOL(<fs_mw_err>).
          TRY.
              <fs_mw_err>->after( lo_context ).
            CATCH cx_root.
          ENDTRY.
        ENDLOOP.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_server~set_error_handler.
    ms_context-error_handler = io_error_handler.
  ENDMETHOD.

  METHOD zif_via_server~set_serializer.
    ms_context-serializer = io_serializer.
  ENDMETHOD.

  METHOD zif_via_server~set_cache.
    ms_context-cache = io_cache.
  ENDMETHOD.

  METHOD zif_via_server~set_container.
    ms_context-container = io_container.
  ENDMETHOD.

  METHOD zif_via_server~use.
    APPEND io_middleware TO ms_context-middlewares.
  ENDMETHOD.

  METHOD match_route.
    DATA lv_matched TYPE abap_bool.

    LOOP AT ms_context-routes ASSIGNING FIELD-SYMBOL(<fs_route>).
      lcl_route_matcher=>match_path( EXPORTING iv_path       = iv_path
                                               iv_route      = <fs_route>-path
                                     IMPORTING ev_matched    = lv_matched
                                               et_parameters = et_parameters ).
      IF lv_matched = abap_false.
        CONTINUE.
      ENDIF.

      IF iv_method <> <fs_route>-method.
        APPEND <fs_route>-method TO et_allowed_methods.
        CLEAR et_parameters.
        CONTINUE.
      ENDIF.

      eo_route = <fs_route>-handler.
      EXIT.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
