CLASS zcl_via_context DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Initializes a new context instance
    "! @parameter io_http       | HTTP abstraction
    "! @parameter io_cache      | Cache instance
    "! @parameter io_container  | DI container instance
    "! @parameter io_serializer | Serializer instance
    "! @parameter it_parameters | Path parameters table
    METHODS constructor
      IMPORTING io_http       TYPE REF TO zif_via_http
                io_cache      TYPE REF TO zif_via_cache
                io_container  TYPE REF TO zif_via_container
                io_serializer TYPE REF TO zif_via_serializer
                it_parameters TYPE zif_via_context=>ty_t_name_value.

    INTERFACES zif_via_context.

  PRIVATE SECTION.
    DATA mo_http       TYPE REF TO zif_via_http.
    DATA mo_cache      TYPE REF TO zif_via_cache.
    DATA mo_container  TYPE REF TO zif_via_container.
    DATA mo_serializer TYPE REF TO zif_via_serializer.
    DATA mt_parameters TYPE zif_via_context=>ty_t_name_value.
ENDCLASS.


CLASS zcl_via_context IMPLEMENTATION.
  METHOD zif_via_context~get_serializer.
    ro_serializer = mo_serializer.
  ENDMETHOD.

  METHOD zif_via_context~get_header.
    rv_result = mo_http->get_header( iv_name ).
  ENDMETHOD.

  METHOD zif_via_context~get_path.
    rv_result = mo_http->get_path( ).
  ENDMETHOD.

  METHOD zif_via_context~get_method.
    rv_result = mo_http->get_method( ).
  ENDMETHOD.

  METHOD constructor.
    mo_http = io_http.
    mo_cache = io_cache.
    mo_container = io_container.
    mo_serializer = io_serializer.
    mt_parameters = it_parameters.
  ENDMETHOD.

  METHOD zif_via_context~get_cache.
    ro_cache = mo_cache.
  ENDMETHOD.

  METHOD zif_via_context~get_container.
    ro_container = mo_container.
  ENDMETHOD.

  METHOD zif_via_context~param.
    rv_result = VALUE #( mt_parameters[ name = iv_name ]-value OPTIONAL ).
  ENDMETHOD.

  METHOD zif_via_context~query.
    rv_result = mo_http->get_query( iv_name ).
  ENDMETHOD.

  METHOD zif_via_context~bind.
    mo_serializer->deserialize( EXPORTING iv_serialized = mo_http->get_text( )
                                CHANGING  cv_data       = cv_data ).
  ENDMETHOD.

  METHOD zif_via_context~status.
    mo_http->set_status( iv_status ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~header.
    mo_http->set_header( iv_name  = iv_name
                         iv_value = iv_value ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~json.
    DATA(lo_serializer) = CAST zif_via_serializer( NEW zcl_via_serializer_json( ) ).
    mo_http->set_text( lo_serializer->serialize( iv_data ) ).
    mo_http->set_header( iv_name  = 'content-type'
                         iv_value = lo_serializer->content_type( ) ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~xml.
    DATA(lo_serializer) = CAST zif_via_serializer( NEW zcl_via_serializer_xml( ) ).
    mo_http->set_text( lo_serializer->serialize( iv_data ) ).
    mo_http->set_header( iv_name  = 'content-type'
                         iv_value = lo_serializer->content_type( ) ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~text.
    mo_http->set_text( iv_text ).
    mo_http->set_header( iv_name  = 'content-type'
                         iv_value = 'text/plain; charset=utf-8' ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~file.
    mo_http->set_binary( iv_binary ).
    mo_http->set_header( iv_name  = 'content-type'
                         iv_value = iv_content_type ).
    IF iv_filename IS NOT INITIAL.
      mo_http->set_header( iv_name  = 'content-disposition'
                           iv_value = |attachment; filename="{ iv_filename }"| ).
    ENDIF.
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~ok.
    mo_http->set_status( 200 ).
    IF iv_data IS SUPPLIED.
      zif_via_context~json( iv_data ).
    ENDIF.
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~created.
    mo_http->set_status( 201 ).
    IF iv_uri IS SUPPLIED AND iv_uri IS NOT INITIAL.
      mo_http->set_header( iv_name  = 'Location'
                           iv_value = iv_uri ).
    ENDIF.
    IF iv_data IS SUPPLIED.
      zif_via_context~json( iv_data ).
    ENDIF.
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~accepted.
    mo_http->set_status( 202 ).
    IF iv_data IS SUPPLIED.
      zif_via_context~json( iv_data ).
    ENDIF.
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~no_content.
    mo_http->set_status( 204 ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~bad_request.
    zcx_via_error=>raise_bad_request( iv_detail = iv_detail ).
  ENDMETHOD.

  METHOD zif_via_context~unauthorized.
    RAISE EXCEPTION NEW zcx_via_error( iv_status = 401
                                       iv_title  = 'Unauthorized'
                                       iv_detail = iv_detail ).
  ENDMETHOD.

  METHOD zif_via_context~forbidden.
    RAISE EXCEPTION NEW zcx_via_error( iv_status = 403
                                       iv_title  = 'Forbidden'
                                       iv_detail = iv_detail ).
  ENDMETHOD.

  METHOD zif_via_context~not_found.
    zcx_via_error=>raise_not_found( iv_detail = iv_detail ).
  ENDMETHOD.

  METHOD zif_via_context~conflict.
    RAISE EXCEPTION NEW zcx_via_error( iv_status = 409
                                       iv_title  = 'Conflict'
                                       iv_detail = iv_detail ).
  ENDMETHOD.

  METHOD zif_via_context~redirect.
    DATA(lv_code) = COND i( WHEN iv_permanent = abap_true THEN 301 ELSE 302 ).
    mo_http->set_status( lv_code ).
    mo_http->set_header( iv_name  = 'Location'
                         iv_value = iv_url ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~method.
    rv_result = mo_http->get_method( ).
  ENDMETHOD.

  METHOD zif_via_context~path.
    rv_result = mo_http->get_path( ).
  ENDMETHOD.

  METHOD zif_via_context~download.
    mo_http->set_binary( iv_data ).
    mo_http->set_header( iv_name  = 'content-type'
                         iv_value = 'application/octet-stream' ).
    mo_http->set_header( iv_name  = 'content-disposition'
                         iv_value = |attachment; filename="{ iv_filename }"| ).
    ro_context = me.
  ENDMETHOD.

  METHOD zif_via_context~client_ip.
    rv_result = mo_http->get_header( 'x-forwarded-for' ).
    IF rv_result IS INITIAL.
      rv_result = mo_http->get_header( 'x-real-ip' ).
    ENDIF.
    IF rv_result IS INITIAL.
      rv_result = mo_http->get_header( '~remote_addr' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_context~is_json.
    DATA(lv_ct) = to_lower( mo_http->get_header( 'content-type' ) ).
    IF lv_ct CS 'application/json'.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_context~is_xml.
    DATA(lv_ct) = to_lower( mo_http->get_header( 'content-type' ) ).
    IF lv_ct CS 'xml'.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
