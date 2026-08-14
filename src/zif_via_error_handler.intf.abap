INTERFACE zif_via_error_handler PUBLIC.

  "! Converts an exception to an RFC 7807 problem details response
  "! @parameter ix_error   | Exception to handle
  "! @parameter io_context | Context whose response is written
  METHODS handle
    IMPORTING ix_error   TYPE REF TO cx_root
              io_context TYPE REF TO zif_via_context.

ENDINTERFACE.
