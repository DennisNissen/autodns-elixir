defmodule AutoDNS do
  @moduledoc """
  Elixir client for the AutoDNS JSON API by InterNetX.

  AutoDNS provides domain registration, DNS management, SSL certificates,
  and related services. This library provides a complete Elixir interface
  to the [AutoDNS JSON API](https://help.internetx.com/pages/viewpage.action?pageId=14878418).

  ## Quick Start

      # Create a client
      client = AutoDNS.client("username", "password")

      # With a specific context
      client = AutoDNS.client("username", "password", context: 4)

      # Look up a domain
      {:ok, domain} = AutoDNS.Domains.get(client, "example.com")

      # Search for domains
      {:ok, domains} = AutoDNS.Domains.list(client, %{
        "keys" => ["name", "registryStatus"],
        "filters" => [%{"key" => "name", "value" => "example*", "operator" => "LIKE"}]
      })

      # Create a DNS zone
      {:ok, zone} = AutoDNS.Zones.create(client, %{
        "origin" => "example.com",
        "resourceRecords" => [
          %{"name" => "www", "type" => "A", "value" => "1.2.3.4", "ttl" => 3600}
        ]
      })

      # Get SSL certificate info
      {:ok, cert} = AutoDNS.Certificates.get(client, 12345)

  ## Configuration

  The client requires your AutoDNS credentials:

  - **Username**: Your AutoDNS API username
  - **Password**: Your AutoDNS API password
  - **Context** (optional): Your customer context number (e.g., `4`)

  ## Options

  Additional options can be passed to `client/3`:

  - `:context` - Customer context number
  - `:owner_user` - Owner user for sub-user operations
  - `:owner_context` - Owner context for sub-user operations
  - `:session_id` - Session ID for session-based auth
  - `:two_fa_token` - 2FA token for two-factor authentication
  - `:demo` - Set to `true` for demo/sandbox mode
  - `:base_url` - Override the base URL (useful for testing)

  """

  alias AutoDNS.Client

  @doc """
  Creates a new AutoDNS API client.

  ## Parameters

  - `username` - Your AutoDNS API username
  - `password` - Your AutoDNS API password
  - `opts` - Optional keyword list (see module docs for available options)

  ## Examples

      client = AutoDNS.client("user", "pass")
      client = AutoDNS.client("user", "pass", context: 4)
      client = AutoDNS.client("user", "pass", context: 4, demo: true)

  """
  @spec client(String.t(), String.t(), keyword()) :: Client.t()
  def client(username, password, opts \\ []) do
    Client.new(username, password, opts)
  end
end
