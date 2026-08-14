CLASS zcl_via_cache DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_via_cache.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_entry,
        key        TYPE string,
        value      TYPE string,
        expires_at TYPE timestamp,
      END OF ty_s_entry.
    TYPES ty_t_entry TYPE HASHED TABLE OF ty_s_entry WITH UNIQUE KEY key.

    DATA mt_entries TYPE ty_t_entry.

    "! Checks whether a timestamp is in the past
    "! @parameter iv_expires_at | Expiry timestamp
    "! @parameter rv_expired    | True if expired
    METHODS is_expired
      IMPORTING iv_expires_at     TYPE timestamp
      RETURNING VALUE(rv_expired) TYPE abap_bool.

ENDCLASS.


CLASS zcl_via_cache IMPLEMENTATION.
  METHOD zif_via_cache~get.
    ASSIGN mt_entries[ key = iv_key ] TO FIELD-SYMBOL(<fs_entry>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    IF is_expired( <fs_entry>-expires_at ) = abap_true.
      DELETE TABLE mt_entries WITH TABLE KEY key = iv_key.
      RETURN.
    ENDIF.
    rv_value = <fs_entry>-value.
  ENDMETHOD.

  METHOD zif_via_cache~is_hit.
    ASSIGN mt_entries[ key = iv_key ] TO FIELD-SYMBOL(<fs_entry>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    rv_hit = xsdbool( is_expired( <fs_entry>-expires_at ) = abap_false ).
  ENDMETHOD.

  METHOD zif_via_cache~set.
    DATA lv_expires TYPE timestamp.

    GET TIME STAMP FIELD lv_expires.
    lv_expires = lv_expires + iv_ttl.

    ASSIGN mt_entries[ key = iv_key ] TO FIELD-SYMBOL(<fs_entry>).
    IF sy-subrc = 0.
      <fs_entry>-value      = iv_value.
      <fs_entry>-expires_at = lv_expires.
    ELSE.
      INSERT VALUE ty_s_entry( key        = iv_key
                               value      = iv_value
                               expires_at = lv_expires ) INTO TABLE mt_entries.
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_cache~delete.
    DELETE TABLE mt_entries WITH TABLE KEY key = iv_key.
  ENDMETHOD.

  METHOD zif_via_cache~clear.
    CLEAR mt_entries.
  ENDMETHOD.

  METHOD is_expired.
    DATA lv_now TYPE timestamp.

    GET TIME STAMP FIELD lv_now.
    rv_expired = xsdbool( iv_expires_at < lv_now ).
  ENDMETHOD.
ENDCLASS.
