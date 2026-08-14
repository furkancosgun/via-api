INTERFACE zif_via_middleware PUBLIC.

  "! Pre-execution middleware phase (runs before handler)
  "! Return abap_false to short-circuit pipeline
  "! @parameter io_context    | Request context
  "! @parameter rv_next       | True to continue, false to abort
  "! @raising   zcx_via_error | On middleware exception
  METHODS before
    IMPORTING io_context     TYPE REF TO zif_via_context
    RETURNING VALUE(rv_next) TYPE abap_bool
    RAISING   zcx_via_error.

  "! Post-execution middleware phase (runs after handler/response)
  "! @parameter io_context    | Request context
  "! @raising   zcx_via_error | On middleware exception
  METHODS after
    IMPORTING io_context TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

ENDINTERFACE.
