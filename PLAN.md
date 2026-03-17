# AutoDNS Elixir API Client — Implementation Plan

## Overview

A feature-complete Elixir client for the [AutoDNS JSON API](https://help.internetx.com/pages/viewpage.action?pageId=14878418) by InterNetX.
Follows the patterns established in [moco-elixir](https://github.com/DennisNissen/moco-elixir): typed structs via `use AutoDNS.Schema`, a thin `AutoDNS.Client` HTTP layer built on Req, Plug-based mock server for testing, and full typespecs throughout.

**Base URL:** `https://api.autodns.com/v1`
**Auth:** HTTP Basic Auth (`username:password`)
**API Spec:** [domainrobot.json](https://github.com/InterNetX/domainrobot-api/blob/master/src/domainrobot.json) (~180 non-bulk endpoints, 488 schemas)

---

## Phase 1 — Project Skeleton

- `mix new autodns --module AutoDNS`
- Dependencies: `req`, `jason`, `plug` (test only)
- `.gitignore`, `.formatter.exs`, `config/config.exs`
- GitHub Actions CI workflow (`.github/workflows/ci.yml`)
- `elixirc_paths/1` for test support files

## Phase 2 — Core Modules

| Module | Purpose |
|--------|---------|
| `AutoDNS` | Top-level entry point, `client/3` factory |
| `AutoDNS.Client` | HTTP client struct + `get/post/put/patch/delete` via Req |
| `AutoDNS.Response` | Wraps HTTP response (status, body, headers) |
| `AutoDNS.Error` | Error struct with status, message, body; `from_response/1` |
| `AutoDNS.Schema` | `__using__` macro to generate struct + `from_map/1` / `from_list/1` |
| `AutoDNS.Config` | Runtime config helpers (headers like `X-Domainrobot-Context`, etc.) |

### Client details

- Struct fields: `username`, `password`, `base_url`, `context`, `opts`
- Default base URL: `https://api.autodns.com/v1`
- Auth: HTTP Basic via `Authorization: Basic base64(user:pass)`
- Optional headers: `X-Domainrobot-Context`, `X-Domainrobot-Owner-User`, `X-Domainrobot-Owner-Context`, `X-Domainrobot-SessionId`, `X-Domainrobot-2FA-Token`, `X-Domainrobot-Demo`, `X-Domainrobot-WS`, `X-Domainrobot-Bulk-Limit`
- Plug support for testing (same pattern as moco-elixir)

### Response wrapper

The AutoDNS API returns JSON with a standard envelope:
```json
{
  "stid": "...",
  "status": { "code": "...", "text": "...", "type": "SUCCESS" },
  "object": { ... },
  "data": [ ... ]
}
```

`AutoDNS.Response` will expose: `stid`, `status`, `data` (list), `object` (single).

## Phase 3 — Resource Modules

Each API resource gets two modules:
1. **Schema module** (e.g., `AutoDNS.Domain`) — struct definition via `use AutoDNS.Schema`
2. **Operations module** (e.g., `AutoDNS.Domains`) — CRUD + special actions

### Resource Groups

#### Domain Management
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Domains` | create, list (search), get, update, delete, transfer, restore, renew, ownerChange, trade, buy, authinfo1, authinfo2, cancelation, statusUpdate, dnssec, domainSafe, services |
| `AutoDNS.DomainCancelations` | create, list, get, update, delete |
| `AutoDNS.DomainPreregs` | create, list, get, update, delete, confirm |
| `AutoDNS.DomainPremiums` | get |
| `AutoDNS.DomainStudio` | search, classify, socialMediaCheck, tlds |
| `AutoDNS.DomainSafe` | contacts (CRUD), objects (CRUD), users (CRUD) |
| `AutoDNS.TransferOuts` | list, get, answer |

#### DNS / Zone Management
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Zones` | create, list, get, update, delete, patch, stream, import, axfr, copy, migrate, restore, comment, domainSafe, history |
| `AutoDNS.ZoneQueries` | list, baseList |

#### Contact Management
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Contacts` | create, list, get, update, delete, comment, domainSafe, restore, verification |
| `AutoDNS.ContactDocuments` | create, get, patch, delete, copy |

#### SSL / Certificate Management
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Certificates` | create, list, get, delete, reissue, renew, revoke, prepareOrder, realtime, installCheck, checkVmcData, comment, siteSeal |
| `AutoDNS.SslContacts` | create, list, get, update, delete |

#### User Management
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Users` | create, list, get, update, delete, lock, unlock, resendInvite, acl, profile, serviceProfile, sso, verification, copy, newPassword |
| `AutoDNS.OTPAuth` | get, create |

#### Account / Billing
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Account` | info, update (contextHost) |
| `AutoDNS.Invoices` | list, get |
| `AutoDNS.Subscriptions` | create, list, update, delete, upgrade, cancelation |
| `AutoDNS.SubjectProducts` | list |

#### Infrastructure
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.BackupMx` | create, list, get, delete |
| `AutoDNS.MailProxies` | create, list, get, update, delete |
| `AutoDNS.Redirects` | create, list, get, update, delete |

#### Jobs & Polling
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Jobs` | list, get, cancel, confirm, resendApproverEmail, resendPhoneAuthorization, historyList, historyGet |
| `AutoDNS.Polls` | get, confirm |

#### Trademark
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.TmchMarks` | create, list, get, update, delete, confirm, transfer, import, documents |
| `AutoDNS.TmchClaims` | list, get, confirm, reject |

#### Session
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Session` | login, logout |

#### Misc
| Module | Endpoints |
|--------|-----------|
| `AutoDNS.Hello` | hello (health check) |
| `AutoDNS.ObjectAssignments` | assign, assignAll |
| `AutoDNS.CustomerPriceLists` | bulkCreate, bulkDelete |

### Bulk Operations

Bulk operations will be methods on the relevant resource module (e.g., `AutoDNS.Domains.bulk_create/2`, `AutoDNS.Domains.bulk_patch/2`).

## Phase 4 — Schema Structs

Key schema structs (with typed fields from OpenAPI spec):

- `AutoDNS.Domain` — name, registryStatus, nameServers, contacts, etc. (52 fields)
- `AutoDNS.Zone` — name, origin, resourceRecords, virtualNameServer, etc. (29 fields)
- `AutoDNS.Contact` — type, alias, fname, lname, email, address, etc. (29 fields)
- `AutoDNS.Certificate` — name, product, type, csr, server, etc. (50 fields)
- `AutoDNS.User` — user, context, defaultEmail, etc. (31 fields)
- `AutoDNS.Job` — id, status, type, execution, etc. (8 fields)
- `AutoDNS.ResourceRecord` — name, type, value, ttl, pref (for zone records)
- `AutoDNS.NameServer` — name, ttl, ipAddresses
- `AutoDNS.SslContact` — id, fname, lname, organization, etc. (19 fields)
- `AutoDNS.DomainCancelation` — domain, type, execution, etc.
- `AutoDNS.Query` — filters, view (offset/limit/children/orderBy), orders
- And many more supporting structs...

## Phase 5 — Testing

### Strategy
- **Plug-based mock server** (`AutoDNS.MockServer`) — same approach as moco-elixir
- Mock every endpoint with realistic response data matching the API schema
- Test every public function in every resource module
- Test error handling (4xx responses)
- Test client construction and auth headers
- Test Schema from_map/from_list conversions

### Test structure
```
test/
  autodns_test.exs          # Main test file covering all modules
  support/
    mock_server.ex           # Plug-based mock server
```

## Phase 6 — Documentation & CI

- `@moduledoc` on every module with usage examples
- `@doc` on every public function
- `@spec` on every public function
- `README.md` with Quick Start, installation, configuration, usage examples
- GitHub Actions: `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix test`

## Implementation Order

1. Project init + mix.exs + deps + .gitignore + .formatter.exs
2. Core: Schema, Error, Response, Config, Client, AutoDNS (top-level)
3. Resource modules in order: Hello, Session, Account, Domains, Zones, Contacts, Certificates, SslContacts, Users, OTPAuth, Jobs, Polls, BackupMx, MailProxies, Redirects, Subscriptions, Invoices, TransferOuts, DomainCancelations, DomainPreregs, DomainPremiums, DomainStudio, DomainSafe, TmchMarks, TmchClaims, ContactDocuments, ZoneQueries, SubjectProducts, ObjectAssignments
4. Mock server + exhaustive tests
5. README.md + GitHub Actions CI
6. Final review: `mix format`, `mix compile --warnings-as-errors`, `mix test`
