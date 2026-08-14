INTERFACE zif_via_http
  PUBLIC.

  "! Returns header value by name
  "! @parameter iv_name   | Header key
  "! @parameter rv_result | Header value
  METHODS get_header
    IMPORTING iv_name          TYPE string
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns query string value by name
  "! @parameter iv_name   | Query parameter key
  "! @parameter rv_result | Query parameter value
  METHODS get_query
    IMPORTING iv_name          TYPE string
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns HTTP method (GET, POST, etc.)
  "! @parameter rv_result | HTTP verb
  METHODS get_method
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns request path
  "! @parameter rv_result | Path
  METHODS get_path
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns request body as text
  "! @parameter rv_result | Text payload
  METHODS get_text
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns request body as binary
  "! @parameter rv_result | Binary payload
  METHODS get_binary
    RETURNING VALUE(rv_result) TYPE xstring.

  "! Sets response header
  "! @parameter iv_name  | Header key
  "! @parameter iv_value | Header value
  METHODS set_header
    IMPORTING iv_name  TYPE string
              iv_value TYPE string.

  "! Sets response text body
  "! @parameter iv_text | Text content
  METHODS set_text
    IMPORTING iv_text TYPE string.

  "! Sets response binary body
  "! @parameter iv_binary | Binary content
  METHODS set_binary
    IMPORTING iv_binary TYPE xstring.

  "! Sets response HTTP status code
  "! @parameter iv_status | Status code
  METHODS set_status
    IMPORTING iv_status TYPE i.
ENDINTERFACE.
