INTERFACE zif_via_serializer PUBLIC.

  "! Returns the media type produced/consumed by this serializer
  "! @parameter rv_content_type | Media type, e.g. application/json
  METHODS content_type
    RETURNING VALUE(rv_content_type) TYPE string.

  "! Serializes ABAP data to a textual representation
  "! @parameter iv_data       | ABAP data to serialize
  "! @parameter rv_serialized | Serialized text
  "! @raising   zcx_via_error | If serialization fails
  METHODS serialize
    IMPORTING iv_data              TYPE any
    RETURNING VALUE(rv_serialized) TYPE string
    RAISING   zcx_via_error.

  "! Deserializes text into ABAP data
  "! @parameter iv_serialized | Text to deserialize
  "! @parameter cv_data       | Target data
  "! @raising   zcx_via_error | If deserialization fails
  METHODS deserialize
    IMPORTING iv_serialized TYPE string
    CHANGING  cv_data       TYPE any
    RAISING   zcx_via_error.
ENDINTERFACE.
