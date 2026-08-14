INTERFACE zif_via_context PUBLIC.

  TYPES:
    BEGIN OF ty_s_name_value,
      name  TYPE string,
      value TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE SORTED TABLE OF ty_s_name_value WITH UNIQUE KEY name.

  "! Returns the HTTP method of the request
  "! @parameter rv_result | Uppercased HTTP method
  METHODS get_method
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns the request path
  "! @parameter rv_result | Path without query string
  METHODS get_path
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns a request header
  "! @parameter iv_name   | Header name
  "! @parameter rv_result | Header value, empty if absent
  METHODS get_header
    IMPORTING iv_name          TYPE string
    RETURNING VALUE(rv_result) TYPE string.

  "! Returns the shared cache
  "! @parameter ro_cache | Cache instance
  METHODS get_cache
    RETURNING VALUE(ro_cache) TYPE REF TO zif_via_cache.

  "! Returns the dependency container
  "! @parameter ro_container | Container instance
  METHODS get_container
    RETURNING VALUE(ro_container) TYPE REF TO zif_via_container.

  "! Returns the configured serializer
  "! @parameter ro_serializer | Serializer instance
  METHODS get_serializer
    RETURNING VALUE(ro_serializer) TYPE REF TO zif_via_serializer.

  "! Path parameter shortcut (alias for get_parameter)
  "! @parameter iv_name   | Parameter name
  "! @parameter rv_result | Parameter value
  METHODS param
    IMPORTING iv_name          TYPE string
    RETURNING VALUE(rv_result) TYPE string.

  "! Query parameter shortcut (alias for get_query)
  "! @parameter iv_name   | Query key
  "! @parameter rv_result | Query value
  METHODS query
    IMPORTING iv_name          TYPE string
    RETURNING VALUE(rv_result) TYPE string.

  "! Body deserialization shortcut (alias for get_data)
  "! @parameter cv_data       | Target data
  "! @raising   zcx_via_error | If parsing fails
  METHODS bind
    CHANGING cv_data TYPE any
    RAISING  zcx_via_error.

  "! Fluent status code setter (alias for set_status)
  "! @parameter iv_status  | HTTP status code
  "! @parameter ro_context | This context
  METHODS status
    IMPORTING iv_status         TYPE i
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! Fluent response header setter (alias for set_header)
  "! @parameter iv_name    | Header key
  "! @parameter iv_value   | Header value
  "! @parameter ro_context | This context
  METHODS header
    IMPORTING iv_name           TYPE string
              iv_value          TYPE string
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! Sends JSON response
  "! @parameter iv_data       | Payload data
  "! @parameter ro_context    | This context
  "! @raising   zcx_via_error | If serialization fails
  METHODS json
    IMPORTING iv_data           TYPE any
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

  "! Sends XML response
  "! @parameter iv_data       | Payload data
  "! @parameter ro_context    | This context
  "! @raising   zcx_via_error | If serialization fails
  METHODS xml
    IMPORTING iv_data           TYPE any
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

  "! Sends plain text response
  "! @parameter iv_text    | Plain text content
  "! @parameter ro_context | This context
  METHODS text
    IMPORTING iv_text           TYPE string
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! Sends binary file response with optional attachment filename
  "! @parameter iv_binary       | Binary content
  "! @parameter iv_content_type | Content type string
  "! @parameter iv_filename     | Optional download filename
  "! @parameter ro_context      | This context
  METHODS file
    IMPORTING iv_binary         TYPE xstring
              iv_content_type   TYPE string
              iv_filename       TYPE string OPTIONAL
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! Responds with HTTP 200 OK
  "! @parameter iv_data       | Optional payload
  "! @parameter ro_context    | This context
  "! @raising   zcx_via_error | If serialization fails
  METHODS ok
    IMPORTING iv_data           TYPE any OPTIONAL
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

  "! Responds with HTTP 201 Created
  "! @parameter iv_data       | Optional payload
  "! @parameter iv_uri        | Optional location URI
  "! @parameter ro_context    | This context
  "! @raising   zcx_via_error | If serialization fails
  METHODS created
    IMPORTING iv_data           TYPE any    OPTIONAL
              iv_uri            TYPE string OPTIONAL
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

  "! Responds with HTTP 202 Accepted
  "! @parameter iv_data       | Optional payload
  "! @parameter ro_context    | This context
  "! @raising   zcx_via_error | If serialization fails
  METHODS accepted
    IMPORTING iv_data           TYPE any OPTIONAL
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

  "! Responds with HTTP 204 No Content
  "! @parameter ro_context | This context
  METHODS no_content
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! Responds with HTTP 400 Bad Request
  "! @parameter iv_detail     | Detail error message
  "! @raising   zcx_via_error | VIA Exception
  METHODS bad_request
    IMPORTING iv_detail TYPE string DEFAULT 'Bad Request'
    RAISING   zcx_via_error.

  "! Responds with HTTP 401 Unauthorized
  "! @parameter iv_detail     | Detail error message
  "! @raising   zcx_via_error | VIA Exception
  METHODS unauthorized
    IMPORTING iv_detail TYPE string DEFAULT 'Unauthorized'
    RAISING   zcx_via_error.

  "! Responds with HTTP 403 Forbidden
  "! @parameter iv_detail     | Detail error message
  "! @raising   zcx_via_error | VIA Exception
  METHODS forbidden
    IMPORTING iv_detail TYPE string DEFAULT 'Forbidden'
    RAISING   zcx_via_error.

  "! Responds with HTTP 404 Not Found
  "! @parameter iv_detail     | Detail error message
  "! @raising   zcx_via_error | VIA Exception
  METHODS not_found
    IMPORTING iv_detail TYPE string DEFAULT 'Not Found'
    RAISING   zcx_via_error.

  "! Responds with HTTP 409 Conflict
  "! @parameter iv_detail     | Detail error message
  "! @raising   zcx_via_error | VIA Exception
  METHODS conflict
    IMPORTING iv_detail TYPE string DEFAULT 'Conflict'
    RAISING   zcx_via_error.

  "! Responds with HTTP 301/302 Redirect
  "! @parameter iv_url       | Target redirect URL
  "! @parameter iv_permanent | True for 301 Permanent, false for 302 Temporary
  "! @parameter ro_context   | This context
  METHODS redirect
    IMPORTING iv_url            TYPE string
              iv_permanent      TYPE abap_bool DEFAULT abap_false
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! HTTP method shortcut (alias for get_method)
  "! @parameter rv_result | Uppercased HTTP method
  METHODS method
    RETURNING VALUE(rv_result) TYPE string.

  "! Request path shortcut (alias for get_path)
  "! @parameter rv_result | Request path string
  METHODS path
    RETURNING VALUE(rv_result) TYPE string.

  "! Binary attachment download shortcut
  "! @parameter iv_data     | Binary file content
  "! @parameter iv_filename | Attachment filename
  "! @parameter ro_context  | This context
  METHODS download
    IMPORTING iv_data           TYPE xstring
              iv_filename       TYPE string
    RETURNING VALUE(ro_context) TYPE REF TO zif_via_context.

  "! Client IP address lookup
  "! @parameter rv_result | Client IP address
  METHODS client_ip
    RETURNING VALUE(rv_result) TYPE string.

  "! Checks if request Content-Type is JSON
  "! @parameter rv_result | True if request is JSON
  METHODS is_json
    RETURNING VALUE(rv_result) TYPE abap_bool.

  "! Checks if request Content-Type is XML
  "! @parameter rv_result | True if request is XML
  METHODS is_xml
    RETURNING VALUE(rv_result) TYPE abap_bool.

ENDINTERFACE.
