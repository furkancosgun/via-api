*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_cloud_service DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_request  TYPE REF TO object
                io_response TYPE REF TO object.

    INTERFACES zif_via_http.

  PRIVATE SECTION.
    DATA mo_request  TYPE REF TO object.
    DATA mo_response TYPE REF TO object.
ENDCLASS.


CLASS lcl_cloud_service IMPLEMENTATION.
  METHOD constructor.
    mo_request = io_request.
    mo_response = io_response.
  ENDMETHOD.

  METHOD zif_via_http~get_binary.
    TRY.
        CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_BINARY')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_header.
    DATA(lv_upper) = to_upper( iv_name ).
    DATA(lv_lower) = to_lower( iv_name ).

    CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_HEADER_FIELD')
      EXPORTING i_name  = iv_name
      RECEIVING r_value = rv_result.

    IF rv_result IS INITIAL.
      CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_HEADER_FIELD')
        EXPORTING i_name  = lv_upper
        RECEIVING r_value = rv_result.
    ENDIF.

    IF rv_result IS INITIAL.
      CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_HEADER_FIELD')
        EXPORTING i_name  = lv_lower
        RECEIVING r_value = rv_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_http~get_method.
    TRY.
        CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_METHOD')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
        rv_result = zif_via_http~get_header( '~request_method' ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_path.
    TRY.
        CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_REQUEST_URI')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
        rv_result = zif_via_http~get_header( '~request_uri' ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_query.
    TRY.
        CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_FORM_FIELD')
          EXPORTING i_name  = iv_name
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_text.
    TRY.
        CALL METHOD mo_request->('IF_WEB_HTTP_REQUEST~GET_TEXT')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_binary.
    TRY.
        CALL METHOD mo_response->('IF_WEB_HTTP_RESPONSE~SET_BINARY')
          EXPORTING i_data = iv_binary.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_header.
    TRY.
        CALL METHOD mo_response->('IF_WEB_HTTP_RESPONSE~SET_HEADER_FIELD')
          EXPORTING i_name  = iv_name
                    i_value = iv_value.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_status.
    DATA lv_reason TYPE string.

    TRY.
        CALL METHOD mo_response->('IF_WEB_HTTP_RESPONSE~SET_STATUS')
          EXPORTING i_code   = iv_status
                    i_reason = lv_reason.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_text.
    TRY.
        CALL METHOD mo_response->('IF_WEB_HTTP_RESPONSE~SET_TEXT')
          EXPORTING i_text = iv_text.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_onprem_service DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_request  TYPE REF TO object
                io_response TYPE REF TO object.

    INTERFACES zif_via_http.

  PRIVATE SECTION.
    DATA mo_request  TYPE REF TO object.
    DATA mo_response TYPE REF TO object.
ENDCLASS.


CLASS lcl_onprem_service IMPLEMENTATION.
  METHOD constructor.
    mo_request = io_request.
    mo_response = io_response.
  ENDMETHOD.

  METHOD zif_via_http~get_binary.
    CALL METHOD mo_request->('IF_HTTP_REQUEST~GET_DATA')
      RECEIVING data = rv_result.
  ENDMETHOD.

  METHOD zif_via_http~get_header.
    DATA(lv_upper) = to_upper( iv_name ).
    DATA(lv_lower) = to_lower( iv_name ).

    CALL METHOD mo_request->('IF_HTTP_REQUEST~GET_HEADER_FIELD')
      EXPORTING name  = iv_name
      RECEIVING value = rv_result.

    IF rv_result IS INITIAL.
      CALL METHOD mo_request->('IF_HTTP_REQUEST~GET_HEADER_FIELD')
        EXPORTING name  = lv_upper
        RECEIVING value = rv_result.
    ENDIF.

    IF rv_result IS INITIAL.
      CALL METHOD mo_request->('IF_HTTP_REQUEST~GET_HEADER_FIELD')
        EXPORTING name  = lv_lower
        RECEIVING value = rv_result.
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_http~get_method.
    rv_result = zif_via_http~get_header( '~request_method' ).
  ENDMETHOD.

  METHOD zif_via_http~get_path.
    rv_result = zif_via_http~get_header( '~request_uri' ).
    IF rv_result IS INITIAL.
      rv_result = zif_via_http~get_header( '~path' ).
    ENDIF.
    IF rv_result IS INITIAL.
      rv_result = zif_via_http~get_header( '~path_info' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_http~get_query.
    CALL METHOD mo_request->('IF_HTTP_REQUEST~GET_FORM_FIELD')
      EXPORTING name  = iv_name
      RECEIVING value = rv_result.
  ENDMETHOD.

  METHOD zif_via_http~get_text.
    CALL METHOD mo_request->('IF_HTTP_REQUEST~GET_CDATA')
      RECEIVING data = rv_result.
  ENDMETHOD.

  METHOD zif_via_http~set_binary.
    CALL METHOD mo_response->('IF_HTTP_RESPONSE~SET_DATA')
      EXPORTING data = iv_binary.
  ENDMETHOD.

  METHOD zif_via_http~set_header.
    CALL METHOD mo_response->('IF_HTTP_RESPONSE~SET_HEADER_FIELD')
      EXPORTING name  = iv_name
                value = iv_value.
  ENDMETHOD.

  METHOD zif_via_http~set_status.
    DATA lv_reason TYPE string.

    CALL METHOD mo_response->('IF_HTTP_RESPONSE~SET_STATUS')
      EXPORTING code   = iv_status
                reason = lv_reason.
  ENDMETHOD.

  METHOD zif_via_http~set_text.
    CALL METHOD mo_response->('IF_HTTP_RESPONSE~SET_CDATA')
      EXPORTING data = iv_text.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_route_matcher DEFINITION.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_result,
        matched    TYPE abap_bool,
        parameters TYPE zif_via_context=>ty_t_name_value,
      END OF ty_s_result.

    CLASS-METHODS match_path
      IMPORTING iv_path          TYPE string
                iv_route         TYPE string
      RETURNING VALUE(rs_result) TYPE ty_s_result.

  PRIVATE SECTION.
    CLASS-METHODS normalize_path
      IMPORTING iv_path        TYPE string
      RETURNING VALUE(rv_path) TYPE string.

    CLASS-METHODS is_catch_all
      IMPORTING iv_segment       TYPE string
      RETURNING VALUE(rv_result) TYPE abap_bool.

    CLASS-METHODS is_placeholder
      IMPORTING iv_segment       TYPE string
      RETURNING VALUE(rv_result) TYPE abap_bool.

    CLASS-METHODS placeholder_name
      IMPORTING iv_segment     TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    CLASS-METHODS join_rest
      IMPORTING iv_from          TYPE i
                it_segments      TYPE string_table
      RETURNING VALUE(rv_result) TYPE string.
ENDCLASS.


CLASS lcl_route_matcher IMPLEMENTATION.
  METHOD match_path.
    DATA(lv_path)  = normalize_path( iv_path ).
    DATA(lv_route) = normalize_path( iv_route ).

    IF lv_path = lv_route.
      rs_result-matched = abap_true.
      RETURN.
    ENDIF.

    SPLIT lv_path AT '/' INTO TABLE DATA(lt_path_segments).
    SPLIT lv_route AT '/' INTO TABLE DATA(lt_route_segments).

    DATA(lv_path_index) = 1.

    LOOP AT lt_route_segments ASSIGNING FIELD-SYMBOL(<fs_route_segment>).
      IF is_catch_all( <fs_route_segment> ).
        DATA(lv_rest) = join_rest( iv_from     = lv_path_index
                                   it_segments = lt_path_segments ).

        INSERT VALUE #( name  = placeholder_name( <fs_route_segment> )
                        value = lv_rest )
               INTO TABLE rs_result-parameters.

        rs_result-matched = abap_true.
        RETURN.
      ENDIF.

      IF lines( lt_path_segments ) < lv_path_index.
        RETURN.
      ENDIF.

      DATA(lv_path_segment) = lt_path_segments[ lv_path_index ].

      IF is_placeholder( <fs_route_segment> ).
        INSERT VALUE #( name  = placeholder_name( <fs_route_segment> )
                        value = lv_path_segment )
               INTO TABLE rs_result-parameters.
      ELSEIF <fs_route_segment> <> lv_path_segment.
        RETURN.
      ENDIF.

      lv_path_index += 1.
    ENDLOOP.

    IF lines( lt_path_segments ) + 1 = lv_path_index.
      rs_result-matched = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD normalize_path.
    SPLIT iv_path AT '?' INTO rv_path DATA(lv_query) ##NEEDED.

    rv_path = shift_left( val = shift_right( val = rv_path
                                             sub = '/' )
                          sub = '/' ).
  ENDMETHOD.

  METHOD is_catch_all.
    IF iv_segment = '*'.
      rv_result = abap_true.
      RETURN.
    ENDIF.

    DATA(lv_length) = strlen( iv_segment ).

    IF lv_length >= 3
        AND substring( val = iv_segment
                      off  = 0
                      len  = 2 )            = '{*'
        AND substring( val = iv_segment
                      off  = lv_length - 1
                      len  = 1 )            = '}'.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_placeholder.
    IF is_catch_all( iv_segment ).
      RETURN.
    ENDIF.

    DATA(lv_length) = strlen( iv_segment ).

    IF lv_length >= 2
        AND substring( val = iv_segment
                      off  = 0
                      len  = 1 )            = '{'
        AND substring( val = iv_segment
                      off  = lv_length - 1
                      len  = 1 )            = '}'.
      rv_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD placeholder_name.
    IF iv_segment = '*'.
      rv_name = '*'.
      RETURN.
    ENDIF.

    DATA(lv_length) = strlen( iv_segment ).

    IF is_catch_all( iv_segment ).
      rv_name = substring( val = iv_segment
                           off = 2
                           len = lv_length - 3 ).
    ELSE.
      rv_name = substring( val = iv_segment
                           off = 1
                           len = lv_length - 2 ).
    ENDIF.
  ENDMETHOD.

  METHOD join_rest.
    LOOP AT it_segments ASSIGNING FIELD-SYMBOL(<fs_segment>) FROM iv_from.
      IF rv_result IS INITIAL.
        rv_result = <fs_segment>.
      ELSE.
        rv_result = |{ rv_result }/{ <fs_segment> }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_silent_http DEFINITION.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_http TYPE REF TO zif_via_http.

    INTERFACES zif_via_http.

  PRIVATE SECTION.
    DATA mo_http TYPE REF TO zif_via_http.
ENDCLASS.


CLASS lcl_silent_http IMPLEMENTATION.
  METHOD constructor.
    mo_http = io_http.
  ENDMETHOD.

  METHOD zif_via_http~get_binary.
    rv_result = mo_http->get_binary( ).
  ENDMETHOD.

  METHOD zif_via_http~get_header.
    rv_result = mo_http->get_header( iv_name ).
  ENDMETHOD.

  METHOD zif_via_http~get_method.
    rv_result = mo_http->get_method( ).
  ENDMETHOD.

  METHOD zif_via_http~get_path.
    rv_result = mo_http->get_path( ).
  ENDMETHOD.

  METHOD zif_via_http~get_query.
    rv_result = mo_http->get_query( iv_name ).
  ENDMETHOD.

  METHOD zif_via_http~get_text.
    rv_result = mo_http->get_text( ).
  ENDMETHOD.

  METHOD zif_via_http~set_binary.
    mo_http->set_header( iv_name  = 'content-length'
                         iv_value = |{ xstrlen( iv_binary ) }| ).
  ENDMETHOD.

  METHOD zif_via_http~set_header.
    mo_http->set_header( iv_name  = iv_name
                         iv_value = iv_value ).
  ENDMETHOD.

  METHOD zif_via_http~set_status.
    mo_http->set_status( iv_status ).
  ENDMETHOD.

  METHOD zif_via_http~set_text.
    mo_http->set_header( iv_name  = 'content-length'
                         iv_value = |{ strlen( iv_text ) }| ).
  ENDMETHOD.
ENDCLASS.
