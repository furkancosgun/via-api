INTERFACE zif_via_container PUBLIC.

  "! Registers an object instance under a name
  "! @parameter iv_name     | Service name
  "! @parameter io_instance | Object instance to register
  METHODS set
    IMPORTING iv_name     TYPE string
              io_instance TYPE REF TO object.

  "! Returns the registered instance
  "! @parameter iv_name       | Service name
  "! @parameter ro_instance   | Registered instance
  "! @raising   zcx_via_error | If no instance is registered for the name
  METHODS get
    IMPORTING iv_name            TYPE string
    RETURNING VALUE(ro_instance) TYPE REF TO object
    RAISING   zcx_via_error.
ENDINTERFACE.
