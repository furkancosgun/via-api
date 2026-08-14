INTERFACE zif_via_handler PUBLIC.

  "! Processes one request for the bound route
  "! @parameter io_context    | Request context
  "! @raising   zcx_via_error | If the request cannot be fulfilled
  METHODS handle
    IMPORTING io_context TYPE REF TO zif_via_context
    RAISING   zcx_via_error.

ENDINTERFACE.
