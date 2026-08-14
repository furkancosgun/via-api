INTERFACE zif_via_server PUBLIC.

  "! Registers a GET route
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS get
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers a POST route
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS post
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers a PUT route
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS put
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers a DELETE route
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS delete
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers a PATCH route
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS patch
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers an OPTIONS route
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS options
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers a route for ALL HTTP methods
  "! @parameter iv_path    | Route path, may contain {name} segments
  "! @parameter io_handler | Route handler
  "! @parameter ro_server  | This server, for fluent calls
  METHODS all
    IMPORTING iv_path          TYPE string
              io_handler       TYPE REF TO zif_via_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Registers a global middleware in the pipeline
  "! @parameter io_middleware | Middleware to register
  "! @parameter ro_server     | This server, for fluent calls
  METHODS use
    IMPORTING io_middleware    TYPE REF TO zif_via_middleware
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Replaces the error handler
  "! @parameter io_error_handler | Error handler
  "! @parameter ro_server        | This server, for fluent calls
  METHODS set_error_handler
    IMPORTING io_error_handler TYPE REF TO zif_via_error_handler
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Replaces the default serializer
  "! @parameter io_serializer | Serializer
  "! @parameter ro_server     | This server, for fluent calls
  METHODS set_serializer
    IMPORTING io_serializer    TYPE REF TO zif_via_serializer
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Replaces the dependency container
  "! @parameter io_container | Container instance
  "! @parameter ro_server    | This server, for fluent calls
  METHODS set_container
    IMPORTING io_container     TYPE REF TO zif_via_container
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Replaces the cache instance
  "! @parameter io_cache  | Cache instance
  "! @parameter ro_server | This server, for fluent calls
  METHODS set_cache
    IMPORTING io_cache         TYPE REF TO zif_via_cache
    RETURNING VALUE(ro_server) TYPE REF TO zif_via_server.

  "! Handles an incoming ICF request end to end
  METHODS dispatch.
ENDINTERFACE.
