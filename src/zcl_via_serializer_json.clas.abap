CLASS zcl_via_serializer_json DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Creates a new JSON serializer instance
    "! @parameter iv_pretty_name | Pretty name mode for JSON keys (default: camel_case)
    METHODS constructor
      IMPORTING iv_pretty_name TYPE /ui2/cl_json=>pretty_name_mode DEFAULT /ui2/cl_json=>pretty_mode-camel_case.

    INTERFACES zif_via_serializer.

  PRIVATE SECTION.
    DATA mv_pretty_name TYPE /ui2/cl_json=>pretty_name_mode.
ENDCLASS.


CLASS zcl_via_serializer_json IMPLEMENTATION.
  METHOD constructor.
    mv_pretty_name = iv_pretty_name.
  ENDMETHOD.

  METHOD zif_via_serializer~content_type.
    rv_content_type = 'application/json; charset=utf-8'.
  ENDMETHOD.

  METHOD zif_via_serializer~serialize.
    rv_serialized = /ui2/cl_json=>serialize( data        = iv_data
                                             pretty_name = mv_pretty_name ).
  ENDMETHOD.

  METHOD zif_via_serializer~deserialize.
    /ui2/cl_json=>deserialize( EXPORTING json        = iv_serialized
                                         pretty_name = mv_pretty_name
                               CHANGING  data        = cv_data ).
  ENDMETHOD.
ENDCLASS.
