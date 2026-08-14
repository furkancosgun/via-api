CLASS lcl_middleware_dummy DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_middleware.

    METHODS is_before_called RETURNING VALUE(rv_result) TYPE abap_bool.
    METHODS is_after_called  RETURNING VALUE(rv_result) TYPE abap_bool.

  PROTECTED SECTION.
    DATA mv_before_called TYPE abap_bool.
    DATA mv_after_called  TYPE abap_bool.
ENDCLASS.


CLASS lcl_middleware_dummy IMPLEMENTATION.
  METHOD zif_via_middleware~before.
    mv_before_called = abap_true.
    rv_next = abap_true.
  ENDMETHOD.

  METHOD zif_via_middleware~after.
    mv_after_called = abap_true.
  ENDMETHOD.

  METHOD is_before_called.
    rv_result = mv_before_called.
  ENDMETHOD.

  METHOD is_after_called.
    rv_result = mv_after_called.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_server_pipeline DEFINITION
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_middleware_pipeline FOR TESTING.
    METHODS test_wildcard_route      FOR TESTING.
    METHODS test_all_route           FOR TESTING.
ENDCLASS.


CLASS ltcl_server_pipeline IMPLEMENTATION.
  METHOD test_middleware_pipeline.
    DATA(lo_mw) = NEW lcl_middleware_dummy( ).
    cl_abap_unit_assert=>assert_bound( lo_mw ).
  ENDMETHOD.

  METHOD test_wildcard_route.
    DATA lv_matched TYPE abap_bool.
    DATA lt_params  TYPE zif_via_context=>ty_t_name_value.

    lcl_route_matcher=>match_path( EXPORTING iv_path       = '/files/docs/2026/report.pdf'
                                             iv_route      = '/files/{*filepath}'
                                   IMPORTING ev_matched    = lv_matched
                                             et_parameters = lt_params ).

    cl_abap_unit_assert=>assert_true( lv_matched ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_params ) ).
    cl_abap_unit_assert=>assert_equals( exp = 'docs/2026/report.pdf'
                                        act = lt_params[ 1 ]-value ).
  ENDMETHOD.

  METHOD test_all_route.
    cl_abap_unit_assert=>assert_true( act = abap_true ).
  ENDMETHOD.
ENDCLASS.
