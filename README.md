# VIA API — ABAP Minimal API Framework

[![abaplint](https://img.shields.io/badge/abaplint-0_issues-brightgreen.svg)](https://abaplint.org)
[![ABAP Language](https://img.shields.io/badge/ABAP-Cloud%20%26%20On--Premise-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

**VIA API** is a high-performance, developer-friendly **Minimal API framework for SAP ABAP**, heavily inspired by **C# ASP.NET Core Minimal APIs** and **Node.js Express**. 

Designed for both **SAP S/4HANA On-Premise (SICF)** and **SAP BTP ABAP Environment (Steampunk / Cloud)**, VIA API allows ABAP developers to build clean, modular, and SOLID-compliant RESTful Web APIs with minimal boilerplate.

---

## ✨ Features

- 🚀 **C# Minimal API & Express Ergonomics**: Expressive shortcuts (`param()`, `query()`, `bind()`, `ok()`, `created()`, `bad_request()`, `not_found()`, `redirect()`).
- 🌐 **Dual Deployment**: Native support for **On-Premise (SICF)** via `zcl_via_sicf_node` and **Cloud (SAP BTP)** via `zcl_via_cloud_node`.
- 🔄 **Dual-Phase Middleware Pipeline**: Intercept HTTP requests before (`before`) and after (`after`) handler execution (Response time metrics, Audit logs, Auth, Headers).
- 🧱 **Built-in SOLID Architecture**: Injected Dependency Container (`zif_via_container`), Shared Cache (`zif_via_cache`), and Pluggable Serializers (`zif_via_serializer`).
- ⚠️ **RFC 7807 Problem Details**: Standardized HTTP exception handling returning RFC 7807 compliant JSON error payloads.
- ⚡ **open-abap & Transpiler Ready**: Fully testable locally using `@abaplint/transpiler-cli` and `@abaplint/runtime`.

---

## ⚡ Quick Start

### 1. Define Route Handlers

Create modular local or global route handlers implementing `zif_via_handler`:

```abap
CLASS lcl_get_user_handler DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_via_handler.
ENDCLASS.

CLASS lcl_get_user_handler IMPLEMENTATION.
  METHOD zif_via_handler~handle.
    DATA(lv_id) = io_context->param( 'id' ).

    IF lv_id = '999'.
      io_context->not_found( 'User does not exist' ).
      RETURN.
    ENDIF.

    io_context->ok( VALUE ty_s_user( id = lv_id name = 'Furkan' role = 'Admin' ) ).
  ENDMETHOD.
ENDCLASS.
```

### 2. Register Routes in SICF Node (On-Premise)

```abap
CLASS zcl_via_sicf_node IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA(lo_app) = zcl_via_server=>factory_onprem( server ).

    lo_app->get( iv_path = '/api/v1/users/{id}' io_handler = NEW lcl_get_user_handler( ) ).
    lo_app->post( iv_path = '/api/v1/users'     io_handler = NEW lcl_create_user_handler( ) ).
    lo_app->all( iv_path = '/api/v1/health'     io_handler = NEW lcl_health_handler( ) ).

    lo_app->dispatch( ).
  ENDMETHOD.
ENDCLASS.
```

---

## 📖 API Reference Cheat Sheet

### Request Shortcuts (`zif_via_context`)

| Method | Description | Example |
|---|---|---|
| `param( name )` | Reads a URL path parameter (`{id}` or `{*path}`) | `DATA(lv_id) = c->param( 'id' ).` |
| `query( name )` | Reads a URL query string parameter | `DATA(lv_search) = c->query( 'search' ).` |
| `bind( cv_data )` | Deserializes JSON body into ABAP data | `c->bind( CHANGING cv_user ).` |
| `method()` | Returns the HTTP request method | `DATA(lv_verb) = c->method( ).` |
| `path()` | Returns the URL request path | `DATA(lv_uri) = c->path( ).` |
| `client_ip()` | Gets client IP from `X-Forwarded-For` / `~remote_addr` | `DATA(lv_ip) = c->client_ip( ).` |
| `is_json()` | Returns `abap_true` if Content-Type is JSON | `IF c->is_json( ).` |
| `is_xml()` | Returns `abap_true` if Content-Type is XML | `IF c->is_xml( ).` |
| `get_header( name )` | Reads an HTTP request header | `DATA(lv_token) = c->get_header( 'authorization' ).` |

### Response Shortcuts (`zif_via_context`)

| Method | HTTP Code | Response Helper |
|---|---|---|
| `ok( [data] )` | `200 OK` | `c->ok( ls_user ).` |
| `created( [uri], [data] )` | `201 Created` | `c->created( iv_uri = '/users/1' iv_data = ls_user ).` |
| `accepted( [data] )` | `202 Accepted` | `c->accepted( ls_job ).` |
| `no_content()` | `204 No Content` | `c->no_content( ).` |
| `bad_request( detail )` | `400 Bad Request` | `c->bad_request( 'Invalid email' ).` |
| `unauthorized( detail )` | `401 Unauthorized` | `c->unauthorized( 'Token expired' ).` |
| `forbidden( detail )` | `403 Forbidden` | `c->forbidden( 'Access denied' ).` |
| `not_found( detail )` | `404 Not Found` | `c->not_found( 'User not found' ).` |
| `conflict( detail )` | `409 Conflict` | `c->conflict( 'User already exists' ).` |
| `redirect( url, [perm] )` | `301/302` | `c->redirect( '/login' ).` |
| `json( data )` | `200 OK` | `c->json( ls_data ).` |
| `text( string )` | `200 OK` | `c->text( 'Hello World' ).` |
| `file( bytes, mime, [filename] )` | `200 OK` | `c->file( lv_bin, 'application/pdf', 'doc.pdf' ).` |
| `download( bytes, filename )` | `200 OK` | `c->download( lv_bin, 'export.xlsx' ).` |

---

## 🔄 Dual-Phase Middleware Pipeline

Middlewares implement `zif_via_middleware` to intercept requests before and after handler execution:

```abap
CLASS zcl_via_mw_logger DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_via_middleware.
ENDCLASS.

CLASS zcl_via_mw_logger IMPLEMENTATION.
  METHOD zif_via_middleware~before.
    " Pre-execution filter / Auth check
    rv_next = abap_true.
  ENDMETHOD.

  METHOD zif_via_middleware~after.
    " Post-execution audit / response logging
    DATA(lv_path) = io_context->get_path( ).
  ENDMETHOD.
ENDCLASS.
```

Attach middlewares to the server instance:
```abap
lo_app->use( NEW zcl_via_mw_logger( ) ).
```

---

## 🛠️ Testing & Development

Run linter, transpilation, and unit tests using npm:

```bash
# Check code style & lints
npm run lint

# Automatically fix lint formatting
npm run fix

# Run ABAP Unit tests
npm run unit

# Launch Express server locally
npm run express
```

---

## 📄 License

This project is licensed under the MIT License.
