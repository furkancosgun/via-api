CLASS zcx_via_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Constructor
    "! @parameter iv_type     | URI of the problem type
    "! @parameter iv_title    | Short human readable summary
    "! @parameter iv_status   | HTTP status code
    "! @parameter iv_detail   | Human readable explanation
    "! @parameter iv_instance | URI of the specific occurrence
    "! @parameter ix_previous | Previous exception
    METHODS constructor
      IMPORTING iv_type     TYPE string         OPTIONAL
                iv_title    TYPE string         OPTIONAL
                iv_status   TYPE i              DEFAULT 500
                iv_detail   TYPE string         OPTIONAL
                iv_instance TYPE string         OPTIONAL
                ix_previous TYPE REF TO cx_root OPTIONAL.

    "! Raises a problem details exception
    "! @parameter iv_type       | URI of the problem type
    "! @parameter iv_title      | Short human readable summary
    "! @parameter iv_status     | HTTP status code
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise
      IMPORTING iv_type     TYPE string OPTIONAL
                iv_title    TYPE string OPTIONAL
                iv_status   TYPE i      DEFAULT 500
                iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 404 problem details exception
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_not_found
      IMPORTING iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 400 problem details exception
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_bad_request
      IMPORTING iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 401 problem details exception
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_unauthorized
      IMPORTING iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 403 problem details exception
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_forbidden
      IMPORTING iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 409 problem details exception
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_conflict
      IMPORTING iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 405 problem details exception
    "! @parameter iv_allowed    | Comma separated allowed methods for the Allow header
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_method_not_allowed
      IMPORTING iv_allowed  TYPE string
                iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Raises a 500 problem details exception
    "! @parameter iv_detail     | Human readable explanation
    "! @parameter iv_instance   | URI of the specific occurrence
    "! @raising   zcx_via_error | Always raised
    CLASS-METHODS raise_internal_error
      IMPORTING iv_detail   TYPE string OPTIONAL
                iv_instance TYPE string OPTIONAL
      RAISING   zcx_via_error.

    "! Returns the problem type URI
    "! @parameter rv_type | Problem type URI
    METHODS get_type
      RETURNING VALUE(rv_type) TYPE string.

    "! Returns the short summary
    "! @parameter rv_title | Problem title
    METHODS get_title
      RETURNING VALUE(rv_title) TYPE string.

    "! Returns the HTTP status code
    "! @parameter rv_status | HTTP status code
    METHODS get_status
      RETURNING VALUE(rv_status) TYPE i.

    "! Returns the human readable explanation
    "! @parameter rv_detail | Problem detail
    METHODS get_detail
      RETURNING VALUE(rv_detail) TYPE string.

    "! Returns the URI of the specific occurrence
    "! @parameter rv_instance | Problem instance
    METHODS get_instance
      RETURNING VALUE(rv_instance) TYPE string.

    "! Returns the allowed methods for a 405 response
    "! @parameter rv_allow | Comma separated allowed methods
    METHODS get_allow
      RETURNING VALUE(rv_allow) TYPE string.

    METHODS get_text REDEFINITION.

  PRIVATE SECTION.
    DATA mv_type     TYPE string.
    DATA mv_title    TYPE string.
    DATA mv_status   TYPE i.
    DATA mv_detail   TYPE string.
    DATA mv_instance TYPE string.
    DATA mv_allow    TYPE string.

ENDCLASS.


CLASS zcx_via_error IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = ix_previous ).
    mv_type     = iv_type.
    mv_title    = iv_title.
    mv_status   = iv_status.
    mv_detail   = iv_detail.
    mv_instance = iv_instance.
  ENDMETHOD.

  METHOD raise.
    RAISE EXCEPTION NEW zcx_via_error( iv_type     = iv_type
                                       iv_title    = iv_title
                                       iv_status   = iv_status
                                       iv_detail   = iv_detail
                                       iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD raise_not_found.
    raise( iv_type     = 'about:blank'
           iv_title    = 'Not Found'
           iv_status   = 404
           iv_detail   = iv_detail
           iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD raise_bad_request.
    raise( iv_type     = 'about:blank'
           iv_title    = 'Bad Request'
           iv_status   = 400
           iv_detail   = iv_detail
           iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD raise_unauthorized.
    raise( iv_type     = 'about:blank'
           iv_title    = 'Unauthorized'
           iv_status   = 401
           iv_detail   = iv_detail
           iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD raise_forbidden.
    raise( iv_type     = 'about:blank'
           iv_title    = 'Forbidden'
           iv_status   = 403
           iv_detail   = iv_detail
           iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD raise_conflict.
    raise( iv_type     = 'about:blank'
           iv_title    = 'Conflict'
           iv_status   = 409
           iv_detail   = iv_detail
           iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD raise_method_not_allowed.
    DATA(lo_error) = NEW zcx_via_error( iv_title    = 'Method Not Allowed'
                                        iv_status   = 405
                                        iv_detail   = iv_detail
                                        iv_instance = iv_instance ).
    lo_error->mv_allow = iv_allowed.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD raise_internal_error.
    raise( iv_type     = 'about:blank'
           iv_title    = 'Internal Server Error'
           iv_status   = 500
           iv_detail   = iv_detail
           iv_instance = iv_instance ).
  ENDMETHOD.

  METHOD get_type.
    rv_type = mv_type.
  ENDMETHOD.

  METHOD get_title.
    rv_title = mv_title.
  ENDMETHOD.

  METHOD get_status.
    rv_status = mv_status.
  ENDMETHOD.

  METHOD get_detail.
    rv_detail = mv_detail.
  ENDMETHOD.

  METHOD get_instance.
    rv_instance = mv_instance.
  ENDMETHOD.

  METHOD get_allow.
    rv_allow = mv_allow.
  ENDMETHOD.

  METHOD get_text.
    IF mv_detail IS NOT INITIAL.
      result = mv_detail.
    ELSEIF mv_title IS NOT INITIAL.
      result = mv_title.
    ELSE.
      result = super->get_text( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
