CLASS zcl_via_container DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_via_container.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_entry,
        name     TYPE string,
        instance TYPE REF TO object,
      END OF ty_s_entry.
    TYPES ty_t_entry TYPE HASHED TABLE OF ty_s_entry WITH UNIQUE KEY name.

    DATA mt_entries TYPE ty_t_entry.

ENDCLASS.


CLASS zcl_via_container IMPLEMENTATION.
  METHOD zif_via_container~set.
    ASSIGN mt_entries[ name = iv_name ] TO FIELD-SYMBOL(<fs_entry>).
    IF sy-subrc = 0.
      <fs_entry>-instance = io_instance.
    ELSE.
      INSERT VALUE ty_s_entry( name     = iv_name
                               instance = io_instance ) INTO TABLE mt_entries.
    ENDIF.
  ENDMETHOD.

  METHOD zif_via_container~get.
    ASSIGN mt_entries[ name = iv_name ] TO FIELD-SYMBOL(<fs_entry>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_via_error( iv_status = 500
                                         iv_title  = 'Dependency Not Found'
                                         iv_detail = |No instance registered for "{ iv_name }"| ).
    ENDIF.
    ro_instance = <fs_entry>-instance.
  ENDMETHOD.
ENDCLASS.
