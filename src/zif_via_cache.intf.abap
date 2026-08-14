INTERFACE zif_via_cache PUBLIC.
  "! Returns the cached value, or empty if missing or expired
  "! @parameter iv_key   | Cache key
  "! @parameter rv_value | Cached value
  METHODS get
    IMPORTING iv_key          TYPE string
    RETURNING VALUE(rv_value) TYPE string.

  "! Checks whether a non-expired value exists
  "! @parameter iv_key | Cache key
  "! @parameter rv_hit | True if a valid entry exists
  METHODS is_hit
    IMPORTING iv_key        TYPE string
    RETURNING VALUE(rv_hit) TYPE abap_bool.

  "! Stores a value with a time to live in seconds
  "! @parameter iv_key   | Cache key
  "! @parameter iv_value | Value to store
  "! @parameter iv_ttl   | Time to live in seconds
  METHODS set
    IMPORTING iv_key   TYPE string
              iv_value TYPE string
              iv_ttl   TYPE i DEFAULT 3600.

  "! Removes a single entry
  "! @parameter iv_key | Cache key
  METHODS delete
    IMPORTING iv_key TYPE string.

  "! Removes all entries
  METHODS clear.

ENDINTERFACE.
