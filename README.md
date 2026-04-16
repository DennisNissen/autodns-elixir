# AutoDNS

Elixir client for the [AutoDNS JSON API](https://help.internetx.com/pages/viewpage.action?pageId=14878418) by InterNetX.

[![CI](https://github.com/DennisNissen/autodns-elixir/actions/workflows/ci.yml/badge.svg)](https://github.com/DennisNissen/autodns-elixir/actions/workflows/ci.yml)

## Installation

This package is not yet published to Hex. Install it directly from GitHub by adding it to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:autodns, git: "https://github.com/DennisNissen/autodns-elixir.git"}
  ]
end
```

To pin to a specific tag or branch:

```elixir
def deps do
  [
    {:autodns, git: "https://github.com/DennisNissen/autodns-elixir.git", tag: "v0.1.0"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

## Quick Start

```elixir
# Create a client
client = AutoDNS.client("username", "password", context: 4)

# Look up a domain
{:ok, domain} = AutoDNS.Domains.get(client, "example.com")

# Search for domains
{:ok, domains} = AutoDNS.Domains.list(client, %{
  "filters" => [%{"key" => "name", "value" => "example*", "operator" => "LIKE"}],
  "view" => %{"limit" => 10, "offset" => 0}
})

# Create a DNS zone
{:ok, zone} = AutoDNS.Zones.create(client, %{
  "origin" => "example.com",
  "virtualNameServer" => "a.ns14.net",
  "resourceRecords" => [
    %{"name" => "www", "type" => "A", "value" => "1.2.3.4", "ttl" => 3600}
  ]
})

# Manage contacts
{:ok, contact} = AutoDNS.Contacts.create(client, %{
  "type" => "PERSON",
  "fname" => "John",
  "lname" => "Doe",
  "email" => "john@example.com",
  "address" => ["123 Main St"],
  "city" => "Berlin",
  "country" => "DE",
  "pcode" => "10115"
})

# SSL Certificates
{:ok, cert} = AutoDNS.Certificates.get(client, 12345)

# Check poll messages
{:ok, poll} = AutoDNS.Polls.get(client)
:ok = AutoDNS.Polls.confirm(client, poll.id)
```

## Configuration

The client requires your AutoDNS API credentials:

```elixir
# Basic usage
client = AutoDNS.client("username", "password")

# With context
client = AutoDNS.client("username", "password", context: 4)

# With additional options
client = AutoDNS.client("username", "password",
  context: 4,
  owner_user: "subuser",
  owner_context: 9,
  demo: true
)
```

### Options

| Option | Description |
|--------|-------------|
| `:context` | Customer context number |
| `:owner_user` | Owner user for sub-user operations |
| `:owner_context` | Owner context for sub-user operations |
| `:session_id` | Session ID for session-based auth |
| `:two_fa_token` | 2FA token for two-factor authentication |
| `:demo` | Set to `true` for demo/sandbox mode |
| `:base_url` | Override the base URL (default: `https://api.autodns.com/v1`) |

## Available Modules

### Domain Management
- `AutoDNS.Domains` — Domain registration, transfer, trade, restore, DNSSEC, and more
- `AutoDNS.DomainCancelations` — Domain cancelation management
- `AutoDNS.DomainPreregs` — Domain pre-registration
- `AutoDNS.DomainPremiums` — Premium domain information
- `AutoDNS.DomainStudio` — Domain search and availability checking
- `AutoDNS.DomainSafe` — DomainSafe security layer
- `AutoDNS.TransferOuts` — Outgoing transfer management

### DNS / Zones
- `AutoDNS.Zones` — DNS zone CRUD, import, AXFR, copy, migrate, history
- `AutoDNS.ZoneQueries` — Zone query operations

### Contacts
- `AutoDNS.Contacts` — Contact CRUD, verification, DomainSafe
- `AutoDNS.ContactDocuments` — Contact document management

### SSL / Certificates
- `AutoDNS.Certificates` — Certificate ordering, renewal, revocation
- `AutoDNS.SslContacts` — SSL contact management

### Users & Auth
- `AutoDNS.Users` — User management, ACL, profiles, SSO
- `AutoDNS.OTPAuth` — OTP/2FA configuration
- `AutoDNS.Session` — Session management (login/logout)

### Jobs & Polling
- `AutoDNS.Jobs` — Asynchronous job management
- `AutoDNS.Polls` — Poll message handling

### Infrastructure
- `AutoDNS.BackupMxes` — Backup MX configuration
- `AutoDNS.MailProxies` — Mail proxy management
- `AutoDNS.Redirects` — URL redirect management

### Billing & Account
- `AutoDNS.Account` — Account information
- `AutoDNS.Invoices` — Invoice queries
- `AutoDNS.Subscriptions` — Subscription management
- `AutoDNS.SubjectProducts` — Product catalog

### Trademark
- `AutoDNS.TmchMarks` — TMCH trademark marks
- `AutoDNS.TmchClaims` — TMCH claims notices

### Misc
- `AutoDNS.Hello` — API health check
- `AutoDNS.ObjectAssignments` — Object-user assignments

## License

MIT License. See [LICENSE](LICENSE) for details.
