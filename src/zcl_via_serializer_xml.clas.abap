CLASS zcl_via_serializer_xml DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_via_serializer.

ENDCLASS.


CLASS zcl_via_serializer_xml IMPLEMENTATION.
  METHOD zif_via_serializer~content_type.
    rv_content_type = 'application/xml'.
  ENDMETHOD.

  METHOD zif_via_serializer~serialize.
    TRY.
        CALL TRANSFORMATION id
             SOURCE root = iv_data
             RESULT XML rv_serialized.
      CATCH cx_root INTO DATA(lx_root).
        RAISE EXCEPTION NEW zcx_via_error( iv_status   = 500
                                           iv_title    = 'Internal error'
                                           iv_detail   = 'Response value unserializable'
                                           ix_previous = lx_root ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_via_serializer~deserialize.
    TRY.
        CALL TRANSFORMATION id
             SOURCE XML iv_serialized
             RESULT root = cv_data.
      CATCH cx_root INTO DATA(lx_root).
        RAISE EXCEPTION NEW zcx_via_error( iv_status   = 400
                                           iv_title    = 'Bad Request'
                                           iv_detail   = 'Request body is not valid XML'
                                           ix_previous = lx_root ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
