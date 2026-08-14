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
        CALL METHOD mo_request->('GET_BINARY')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_header.
    TRY.
        CALL METHOD mo_request->('GET_HEADER_FIELD')
          EXPORTING i_name  = iv_name
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_method.
    TRY.
        CALL METHOD mo_request->('GET_METHOD')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
        rv_result = zif_via_http~get_header( '~request_method' ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_path.
    TRY.
        CALL METHOD mo_request->('GET_REQUEST_URI')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
        rv_result = zif_via_http~get_header( '~request_uri' ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_query.
    TRY.
        CALL METHOD mo_request->('GET_FORM_FIELD')
          EXPORTING i_name  = iv_name
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~get_text.
    TRY.
        CALL METHOD mo_request->('GET_TEXT')
          RECEIVING r_value = rv_result.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_binary.
    TRY.
        CALL METHOD mo_response->('SET_BINARY')
          EXPORTING i_data = iv_binary.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_header.
    TRY.
        CALL METHOD mo_response->('SET_HEADER_FIELD')
          EXPORTING i_name  = iv_name
                    i_value = iv_value.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_status.
    DATA lv_reason TYPE string.

    TRY.
        CALL METHOD mo_response->('SET_STATUS')
          EXPORTING i_code   = iv_status
                    i_reason = lv_reason.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_http~set_text.
    TRY.
        CALL METHOD mo_response->('SET_TEXT')
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
    CALL METHOD mo_request->('GET_DATA')
      RECEIVING data = rv_result.
  ENDMETHOD.

  METHOD zif_via_http~get_header.
    DATA(lv_upper) = to_upper( iv_name ).
    DATA(lv_lower) = to_lower( iv_name ).

    CALL METHOD mo_request->('GET_HEADER_FIELD')
      EXPORTING name  = iv_name
      RECEIVING value = rv_result.

    IF rv_result IS INITIAL.
      CALL METHOD mo_request->('GET_HEADER_FIELD')
        EXPORTING name  = lv_upper
        RECEIVING value = rv_result.
    ENDIF.

    IF rv_result IS INITIAL.
      CALL METHOD mo_request->('GET_HEADER_FIELD')
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
    CALL METHOD mo_request->('GET_FORM_FIELD')
      EXPORTING name  = iv_name
      RECEIVING value = rv_result.
  ENDMETHOD.

  METHOD zif_via_http~get_text.
    CALL METHOD mo_request->('GET_CDATA')
      RECEIVING data = rv_result.
  ENDMETHOD.

  METHOD zif_via_http~set_binary.
    CALL METHOD mo_response->('SET_DATA')
      EXPORTING data = iv_binary.
  ENDMETHOD.

  METHOD zif_via_http~set_header.
    CALL METHOD mo_response->('SET_HEADER_FIELD')
      EXPORTING name  = iv_name
                value = iv_value.
  ENDMETHOD.

  METHOD zif_via_http~set_status.
    DATA lv_reason TYPE string.

    CALL METHOD mo_response->('SET_STATUS')
      EXPORTING code   = iv_status
                reason = lv_reason.
  ENDMETHOD.

  METHOD zif_via_http~set_text.
    CALL METHOD mo_response->('SET_CDATA')
      EXPORTING data = iv_text.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_route_matcher DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS match_path
      IMPORTING iv_path              TYPE string
                iv_route             TYPE string
      EXPORTING VALUE(ev_matched)    TYPE abap_bool
                VALUE(et_parameters) TYPE zif_via_context=>ty_t_name_value.

  PRIVATE SECTION.
    CLASS-METHODS normalize_path
      IMPORTING iv_path        TYPE string
      RETURNING VALUE(rv_path) TYPE string.
ENDCLASS.


CLASS lcl_route_matcher IMPLEMENTATION.
  METHOD match_path.
    DATA(lv_path)  = normalize_path( iv_path ).
    DATA(lv_route) = normalize_path( iv_route ).
    DATA lv_rest_path TYPE string.

    IF lv_path = lv_route.
      ev_matched = abap_true.
      RETURN.
    ENDIF.

    IF lv_path IS INITIAL OR lv_route IS INITIAL.
      IF lv_route = '*' OR lv_route CP '{**}'.
        ev_matched = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    SPLIT lv_path AT '/' INTO TABLE DATA(lt_path_segs).
    SPLIT lv_route AT '/' INTO TABLE DATA(lt_route_segs).

    DATA(lv_path_idx)  = 1.
    DATA(lv_route_idx) = 1.

    DO lines( lt_route_segs ) TIMES.
      IF lines( lt_route_segs ) < lv_route_idx.
        EXIT.
      ENDIF.

      DATA(lv_rseg) = lt_route_segs[ lv_route_idx ].

      IF lv_rseg = '*' OR lv_rseg CP '{**}'.
        DATA(lv_param_name) = COND string( WHEN lv_rseg = '*'
                                           THEN '*'
                                           ELSE substring( val = lv_rseg
                                                           off = 2
                                                           len = strlen( lv_rseg ) - 3 ) ).


        CLEAR lv_rest_path.
        LOOP AT lt_path_segs ASSIGNING FIELD-SYMBOL(<fs_pseg>) FROM lv_path_idx.
          IF lv_rest_path IS INITIAL.
            lv_rest_path = <fs_pseg>.
          ELSE.
            lv_rest_path = |{ lv_rest_path }/{ <fs_pseg> }|.
          ENDIF.
        ENDLOOP.

        INSERT VALUE #( name  = lv_param_name
                        value = lv_rest_path )
               INTO TABLE et_parameters.

        ev_matched = abap_true.
        RETURN.
      ENDIF.

      IF lines( lt_path_segs ) < lv_path_idx.
        RETURN.
      ENDIF.

      DATA(lv_pseg) = lt_path_segs[ lv_path_idx ].

      IF lv_rseg CP '{*}'.
        DATA(lv_seg_param) = substring( val = lv_rseg
                                        off = 1
                                        len = strlen( lv_rseg ) - 2 ).
        INSERT VALUE #( name  = lv_seg_param
                        value = lv_pseg )
               INTO TABLE et_parameters.
      ELSEIF lv_rseg <> lv_pseg.
        RETURN.
      ENDIF.

      lv_path_idx  = lv_path_idx + 1.
      lv_route_idx = lv_route_idx + 1.
    ENDDO.

    IF lines( lt_path_segs ) = lv_path_idx - 1 AND lines( lt_route_segs ) = lv_route_idx - 1.
      ev_matched = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD normalize_path.
    SPLIT iv_path AT '?' INTO rv_path DATA(lv_dummy) ##NEEDED.

    rv_path = shift_left( val = shift_right( val = rv_path
                                             sub = '/' )
                          sub = '/' ).
  ENDMETHOD.
ENDCLASS.
