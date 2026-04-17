defmodule AutoDNS.MockServer do
  @moduledoc """
  A Plug-based mock server for testing the AutoDNS API client.

  Used with Req's built-in `plug:` option, which routes HTTP requests
  through this Plug without starting a real HTTP server.

  ## Usage in tests

      client = AutoDNS.MockServer.client()
      {:ok, domain} = AutoDNS.Domains.get(client, "example.com")

  """

  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason
  )

  plug(:dispatch)

  @doc """
  Creates an `AutoDNS.Client` that routes all requests through the mock server.
  """
  def client(opts \\ []) do
    AutoDNS.Client.new(
      "test-user",
      "test-password",
      Keyword.merge([base_url: "", plug: __MODULE__], opts)
    )
  end

  # -- Helper to build AutoDNS-style JSON responses --

  defp autodns_json(conn, status, object, opts \\ []) do
    stid = Keyword.get(opts, :stid, "20240101-app1-test-0001")
    data = Keyword.get(opts, :data)

    body = %{
      "stid" => stid,
      "status" => %{
        "code" => "S0105",
        "text" => "Operation successful.",
        "type" => "SUCCESS"
      }
    }

    body = if object, do: Map.put(body, "object", object), else: body
    body = if data, do: Map.put(body, "data", data), else: body

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  defp autodns_list(conn, data, opts \\ []) do
    autodns_json(conn, 200, nil, Keyword.merge(opts, data: data))
  end

  defp autodns_error(conn, status, message) do
    body = %{
      "stid" => "20240101-app1-test-err",
      "status" => %{
        "code" => "E0001",
        "text" => message,
        "type" => "ERROR"
      },
      "messages" => [%{"text" => message, "status" => "ERROR"}]
    }

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  # =============================================
  # Hello (Health Check)
  # =============================================

  get "/hello" do
    autodns_json(conn, 200, %{"message" => "Hello, World!"})
  end

  # =============================================
  # Session
  # =============================================

  post "/login" do
    autodns_json(conn, 200, %{
      "session" => "sess-abc-123",
      "user" => "test-user",
      "context" => 4,
      "language" => "en"
    })
  end

  get "/logout" do
    autodns_json(conn, 200, nil)
  end

  delete "/logout" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Account
  # =============================================

  get "/account" do
    autodns_json(conn, 200, %{
      "customer" => %{"number" => 12345},
      "currentAccountBalance" => 1000.0,
      "currency" => "EUR"
    })
  end

  post "/account" do
    autodns_json(conn, 200, conn.body_params)
  end

  # =============================================
  # OTP Auth
  # =============================================

  get "/OTPAuth" do
    autodns_json(conn, 200, %{
      "protocol" => "TOTP",
      "algorithm" => "SHA1",
      "digits" => 6,
      "period" => 30
    })
  end

  post "/OTPAuth" do
    autodns_json(conn, 200, %{
      "protocol" => "TOTP",
      "secret" => "JBSWY3DPEHPK3PXP",
      "qrCode" => "data:image/png;base64,..."
    })
  end

  # =============================================
  # Domains
  # =============================================

  post "/domain/_search" do
    autodns_list(conn, [
      %{"name" => "example.com", "registryStatus" => "ACTIVE"},
      %{"name" => "test.org", "registryStatus" => "ACTIVE"}
    ])
  end

  post "/domain" do
    autodns_json(conn, 200, Map.merge(%{"name" => "new-domain.com"}, conn.body_params))
  end

  post "/domain/_transfer" do
    autodns_json(conn, 200, Map.merge(%{"name" => "transferred.com"}, conn.body_params))
  end

  post "/domain/_trade" do
    autodns_json(conn, 200, Map.merge(%{"name" => "traded.com"}, conn.body_params))
  end

  post "/domain/_buy" do
    autodns_json(conn, 200, Map.merge(%{"name" => "bought.com"}, conn.body_params))
  end

  post "/domain/_ownerChange" do
    autodns_json(conn, 200, %{"name" => "owner-changed.com"})
  end

  put "/domain/_services" do
    autodns_json(conn, 200, nil)
  end

  post "/domain/autodelete/_search" do
    autodns_list(conn, [%{"domain" => "expiring.com", "status" => "PENDING"}])
  end

  post "/domain/restore/_search" do
    autodns_list(conn, [%{"name" => "restored.com"}])
  end

  post "/domain/cancelation/_search" do
    autodns_list(conn, [%{"domain" => "cancelled.com", "type" => "DELETE"}])
  end

  post "/domain/:name/cancelation" do
    autodns_json(conn, 200, Map.merge(%{"domain" => name}, conn.body_params))
  end

  get "/domain/:name/cancelation" do
    autodns_json(conn, 200, %{"domain" => name, "type" => "DELETE"})
  end

  put "/domain/:name/cancelation" do
    autodns_json(conn, 200, Map.merge(%{"domain" => name}, conn.body_params))
  end

  delete "/domain/:name/cancelation" do
    autodns_json(conn, 200, nil)
  end

  post "/domain/:name/_authinfo1" do
    autodns_json(conn, 200, %{"authinfo" => "auth-code-123"})
  end

  delete "/domain/:name/_authinfo1" do
    autodns_json(conn, 200, nil)
  end

  post "/domain/:name/_authinfo2" do
    autodns_json(conn, 200, %{"authinfo" => "auth2-code-456"})
  end

  put "/domain/:name/_renew" do
    autodns_json(conn, 200, %{"name" => name})
  end

  put "/domain/:name/_restore" do
    autodns_json(conn, 200, %{"name" => name})
  end

  put "/domain/:name/_dnssec" do
    autodns_json(conn, 200, %{"name" => name})
  end

  put "/domain/:name/_autoDnssecKeyRollover" do
    autodns_json(conn, 200, %{"name" => name})
  end

  put "/domain/:name/_comment" do
    autodns_json(conn, 200, nil)
  end

  put "/domain/:name/_statusUpdate" do
    autodns_json(conn, 200, %{"name" => name})
  end

  put "/domain/:name/_domainSafe" do
    autodns_json(conn, 200, nil)
  end

  delete "/domain/:name/_domainSafe" do
    autodns_json(conn, 200, nil)
  end

  put "/domain/:name/_sendAuthinfoToOwnerc" do
    autodns_json(conn, 200, nil)
  end

  get "/domain/:name" do
    autodns_json(conn, 200, %{
      "name" => name,
      "registryStatus" => "ACTIVE",
      "nameServers" => [%{"name" => "ns1.example.com"}, %{"name" => "ns2.example.com"}]
    })
  end

  put "/domain/:name" do
    autodns_json(conn, 200, Map.merge(%{"name" => name}, conn.body_params))
  end

  # =============================================
  # Domain Pre-Registrations
  # =============================================

  post "/domainPrereg/_confirm" do
    autodns_json(conn, 200, Map.merge(%{"reference" => "prereg-confirmed"}, conn.body_params))
  end

  post "/domainPrereg/_search" do
    autodns_list(conn, [%{"reference" => "prereg-1", "name" => "new.tld"}])
  end

  post "/domainPrereg" do
    autodns_json(conn, 200, Map.merge(%{"reference" => "prereg-new"}, conn.body_params))
  end

  put "/domainPrereg/:ref/_confirm" do
    autodns_json(conn, 200, %{"reference" => ref, "status" => "CONFIRMED"})
  end

  get "/domainPrereg/:ref" do
    autodns_json(conn, 200, %{"reference" => ref, "name" => "test.new"})
  end

  put "/domainPrereg/:ref" do
    autodns_json(conn, 200, Map.merge(%{"reference" => ref}, conn.body_params))
  end

  delete "/domainPrereg/:ref" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Domain Premium
  # =============================================

  get "/domainpremium/:name" do
    autodns_json(conn, 200, %{"name" => name, "price" => 299.99})
  end

  # =============================================
  # DomainStudio
  # =============================================

  post "/domainstudio" do
    autodns_json(conn, 200, %{
      "results" => [%{"domain" => "example.com", "available" => true}]
    })
  end

  post "/domainstudio/classify" do
    autodns_json(conn, 200, %{"classifications" => []})
  end

  post "/domainstudio/socialmedia" do
    autodns_json(conn, 200, %{"results" => []})
  end

  post "/domainstudio/tlds/_search" do
    autodns_list(conn, [%{"tld" => ".com"}, %{"tld" => ".net"}])
  end

  get "/domainstudio/tlds/stats/_search" do
    autodns_json(conn, 200, %{"totalTlds" => 1500})
  end

  # =============================================
  # DomainSafe
  # =============================================

  post "/domainSafeContact/_search" do
    autodns_list(conn, [%{"id" => 1, "name" => "Safe Contact"}])
  end

  post "/domainSafeContact" do
    autodns_json(conn, 200, Map.merge(%{"id" => 100}, conn.body_params))
  end

  get "/domainSafeContact/:id" do
    autodns_json(conn, 200, %{"id" => String.to_integer(id), "name" => "Safe Contact"})
  end

  post "/domainSafeContact/user" do
    autodns_json(conn, 200, conn.body_params)
  end

  put "/domainSafeContact/user" do
    autodns_json(conn, 200, conn.body_params)
  end

  delete "/domainSafeContact/user/:user/:context" do
    autodns_json(conn, 200, nil)
  end

  put "/domainSafeContact/:id" do
    autodns_json(conn, 200, %{"id" => String.to_integer(id)})
  end

  post "/domainSafeObject/_search" do
    autodns_list(conn, [%{"type" => "DOMAIN", "value" => "example.com"}])
  end

  post "/domainSafeObject" do
    autodns_json(conn, 200, conn.body_params)
  end

  delete "/domainSafeObject/:safe_object/:type" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Transfer Out
  # =============================================

  post "/transferout/_search" do
    autodns_list(conn, [%{"domain" => "transfer.com", "status" => "PENDING"}])
  end

  get "/transferout/:name" do
    autodns_json(conn, 200, %{"domain" => name, "status" => "PENDING"})
  end

  post "/transferout/:domain/:type" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Zones
  # =============================================

  post "/zone/_search" do
    autodns_list(conn, [
      %{"origin" => "example.com", "virtualNameServer" => "a.ns14.net"},
      %{"origin" => "test.org", "virtualNameServer" => "a.ns14.net"}
    ])
  end

  post "/zone" do
    autodns_json(conn, 200, Map.merge(%{"origin" => "new-zone.com"}, conn.body_params))
  end

  post "/zone/history/_search" do
    autodns_list(conn, [%{"logId" => 1, "origin" => "example.com"}])
  end

  get "/zone/history/:log_id" do
    autodns_json(conn, 200, %{"logId" => String.to_integer(log_id), "origin" => "example.com"})
  end

  post "/zone/zoneQuery/_search" do
    autodns_list(conn, [%{"origin" => "example.com", "type" => "A"}])
  end

  get "/zone/:name/:vns/_axfr" do
    autodns_json(conn, 200, %{"origin" => name, "virtualNameServer" => vns})
  end

  put "/zone/:name/:vns/_copy" do
    autodns_json(conn, 200, %{"origin" => name})
  end

  put "/zone/:name/:vns/_migrate" do
    autodns_json(conn, 200, %{"origin" => name})
  end

  post "/zone/:name/:vns/_restore" do
    autodns_json(conn, 200, %{"origin" => name})
  end

  put "/zone/:name/:vns/_comment" do
    autodns_json(conn, 200, nil)
  end

  put "/zone/:name/:vns/_domainSafe" do
    autodns_json(conn, 200, nil)
  end

  delete "/zone/:name/:vns/_domainSafe" do
    autodns_json(conn, 200, nil)
  end

  post "/zone/:name/:vns/_import" do
    autodns_json(conn, 200, %{"origin" => name})
  end

  post "/zone/:name/:vns/_stream" do
    autodns_json(conn, 200, nil)
  end

  post "/zone/:name/:vns/zoneQuery/_search" do
    autodns_list(conn, [%{"origin" => name, "type" => "A"}])
  end

  patch "/zone/:name/:vns" do
    autodns_json(
      conn,
      200,
      Map.merge(%{"origin" => name, "virtualNameServer" => vns}, conn.body_params)
    )
  end

  get "/zone/:name/:vns" do
    autodns_json(conn, 200, %{
      "origin" => name,
      "virtualNameServer" => vns,
      "resourceRecords" => [%{"name" => "www", "type" => "A", "value" => "1.2.3.4"}]
    })
  end

  put "/zone/:name/:vns" do
    autodns_json(
      conn,
      200,
      Map.merge(%{"origin" => name, "virtualNameServer" => vns}, conn.body_params)
    )
  end

  delete "/zone/:name/:vns" do
    autodns_json(conn, 200, nil)
  end

  get "/zone/:name" do
    autodns_json(
      conn,
      200,
      %{"type" => "Zone", "value" => name},
      data: [
        %{
          "origin" => name,
          "resourceRecords" => [%{"name" => "www", "type" => "A", "value" => "1.2.3.4"}]
        }
      ]
    )
  end

  put "/zone/:name" do
    autodns_json(conn, 200, Map.merge(%{"origin" => name}, conn.body_params))
  end

  delete "/zone/:name" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Contacts
  # =============================================

  post "/contact/_search" do
    autodns_list(conn, [
      %{"id" => 1, "fname" => "John", "lname" => "Doe"},
      %{"id" => 2, "fname" => "Jane", "lname" => "Smith"}
    ])
  end

  post "/contact/verification/_search" do
    autodns_list(conn, [%{"id" => 1, "status" => "VERIFIED"}])
  end

  get "/contact/verification" do
    autodns_json(conn, 200, %{"status" => "PENDING"})
  end

  put "/contact/verification/_confirm" do
    autodns_json(conn, 200, nil)
  end

  post "/contact/verification/history/_search" do
    autodns_list(conn, [%{"id" => 1}])
  end

  get "/contact/verification/history" do
    autodns_json(conn, 200, %{"entries" => []})
  end

  post "/contact" do
    autodns_json(conn, 200, Map.merge(%{"id" => 100}, conn.body_params))
  end

  get "/contact/:id/verification" do
    autodns_json(conn, 200, %{"contactId" => String.to_integer(id), "status" => "PENDING"})
  end

  post "/contact/:id/verification" do
    autodns_json(conn, 200, %{"contactId" => String.to_integer(id)})
  end

  put "/contact/:id/verification/_resendEmail" do
    autodns_json(conn, 200, nil)
  end

  post "/contact/:id/_restore" do
    autodns_json(conn, 200, nil)
  end

  put "/contact/:id/_comment" do
    autodns_json(conn, 200, nil)
  end

  put "/contact/:id/_domainSafe" do
    autodns_json(conn, 200, nil)
  end

  delete "/contact/:id/_domainSafe" do
    autodns_json(conn, 200, nil)
  end

  post "/contact/:id/document/:type/_copy" do
    autodns_json(conn, 200, %{"type" => type})
  end

  post "/contact/:id/document/:type" do
    autodns_json(conn, 200, Map.merge(%{"type" => type}, conn.body_params))
  end

  get "/contact/:id/document/:type" do
    autodns_json(conn, 200, %{"type" => type, "contactId" => String.to_integer(id)})
  end

  patch "/contact/:id/document/:type" do
    autodns_json(conn, 200, %{"type" => type})
  end

  delete "/contact/:id/document/:type" do
    autodns_json(conn, 200, nil)
  end

  get "/contact/:id" do
    autodns_json(conn, 200, %{
      "id" => String.to_integer(id),
      "fname" => "John",
      "lname" => "Doe",
      "email" => "john@example.com"
    })
  end

  put "/contact/:id" do
    autodns_json(conn, 200, Map.merge(%{"id" => String.to_integer(id)}, conn.body_params))
  end

  delete "/contact/:id" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Certificates
  # =============================================

  post "/certificate/_search" do
    autodns_list(conn, [
      %{"id" => 1, "name" => "example.com", "status" => "ISSUED"},
      %{"id" => 2, "name" => "test.org", "status" => "PENDING"}
    ])
  end

  post "/certificate/_prepareOrder" do
    autodns_json(conn, 200, %{"approverEmails" => ["admin@example.com"]})
  end

  post "/certificate/_realtime" do
    autodns_json(conn, 200, Map.merge(%{"id" => 200}, conn.body_params))
  end

  post "/certificate/_installcheck" do
    autodns_json(conn, 200, %{"valid" => true})
  end

  post "/certificate/_checkVmcData" do
    autodns_json(conn, 200, %{"valid" => true})
  end

  post "/certificate" do
    autodns_json(conn, 200, Map.merge(%{"id" => 100}, conn.body_params))
  end

  get "/certificate/:id/_siteseal" do
    autodns_json(conn, 200, %{"html" => "<div>Site Seal</div>"})
  end

  put "/certificate/:id/_comment" do
    autodns_json(conn, 200, nil)
  end

  put "/certificate/:id/_renew" do
    autodns_json(conn, 200, %{"id" => String.to_integer(id), "status" => "RENEWED"})
  end

  post "/certificate/:id/_revoke" do
    autodns_json(conn, 200, nil)
  end

  get "/certificate/:id" do
    autodns_json(conn, 200, %{
      "id" => String.to_integer(id),
      "name" => "example.com",
      "status" => "ISSUED",
      "product" => "POSITIVE_SSL"
    })
  end

  put "/certificate/:id" do
    autodns_json(conn, 200, Map.merge(%{"id" => String.to_integer(id)}, conn.body_params))
  end

  delete "/certificate/:id" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # SSL Contacts
  # =============================================

  post "/sslcontact/_search" do
    autodns_list(conn, [%{"id" => 1, "fname" => "John", "lname" => "Doe"}])
  end

  post "/sslcontact" do
    autodns_json(conn, 200, Map.merge(%{"id" => 100}, conn.body_params))
  end

  get "/sslcontact/:id" do
    autodns_json(conn, 200, %{
      "id" => String.to_integer(id),
      "fname" => "John",
      "lname" => "Doe",
      "email" => "john@example.com"
    })
  end

  put "/sslcontact/:id" do
    autodns_json(conn, 200, Map.merge(%{"id" => String.to_integer(id)}, conn.body_params))
  end

  delete "/sslcontact/:id" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Users
  # =============================================

  post "/user/_search" do
    autodns_list(conn, [%{"user" => "admin", "context" => 4}])
  end

  post "/user" do
    autodns_json(conn, 200, conn.body_params)
  end

  get "/user/billinglimit" do
    autodns_json(conn, 200, %{"limit" => 10000})
  end

  get "/user/billingterm" do
    autodns_json(conn, 200, %{"term" => "NET30"})
  end

  get "/user/tasklimit" do
    autodns_json(conn, 200, %{"limit" => 500})
  end

  post "/user/salesreport/_search" do
    autodns_list(conn, [%{"month" => "2024-01", "revenue" => 5000}])
  end

  get "/user/:name/:context/acl" do
    autodns_json(conn, 200, %{"user" => name, "acls" => []})
  end

  put "/user/:name/:context/acl" do
    autodns_json(conn, 200, nil)
  end

  get "/user/:name/:context/profile/:prefix" do
    autodns_json(conn, 200, %{"user" => name, "prefix" => prefix})
  end

  get "/user/:name/:context/profile" do
    autodns_json(conn, 200, %{"user" => name, "language" => "en"})
  end

  put "/user/:name/:context/profile" do
    autodns_json(conn, 200, nil)
  end

  put "/user/:name/:context/serviceProfile" do
    autodns_json(conn, 200, nil)
  end

  post "/user/:name/:context/sso" do
    autodns_json(conn, 200, %{"token" => "sso-token-123"})
  end

  post "/user/:name/:context/copy" do
    autodns_json(conn, 200, %{"user" => "copied-user", "context" => String.to_integer(context)})
  end

  post "/user/:name/:context/verification" do
    autodns_json(conn, 200, %{"user" => name})
  end

  put "/user/:name/:context/_lock" do
    autodns_json(conn, 200, nil)
  end

  put "/user/:name/:context/_unlock" do
    autodns_json(conn, 200, nil)
  end

  put "/user/:name/:context/_resendInvite" do
    autodns_json(conn, 200, nil)
  end

  get "/user/:name/:context" do
    autodns_json(conn, 200, %{
      "user" => name,
      "context" => String.to_integer(context),
      "defaultEmail" => "#{name}@example.com",
      "status" => "ACTIVE"
    })
  end

  put "/user/:name/:context" do
    autodns_json(conn, 200, Map.merge(%{"user" => name}, conn.body_params))
  end

  delete "/user/:name/:context" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Jobs
  # =============================================

  post "/job/_search" do
    autodns_list(conn, [
      %{"id" => 1, "status" => "RUNNING", "type" => "DOMAIN_CREATE"},
      %{"id" => 2, "status" => "COMPLETED", "type" => "CERTIFICATE_ORDER"}
    ])
  end

  post "/job/history/_search" do
    autodns_list(conn, [%{"id" => 1, "type" => "DOMAIN_CREATE"}])
  end

  get "/job/history/:id" do
    autodns_json(conn, 200, %{"id" => String.to_integer(id), "type" => "DOMAIN_CREATE"})
  end

  put "/job/:id/_cancel" do
    autodns_json(conn, 200, nil)
  end

  put "/job/:id/_confirm" do
    autodns_json(conn, 200, nil)
  end

  put "/job/:id/_resendApproverEmail" do
    autodns_json(conn, 200, nil)
  end

  put "/job/:id/_resendPhoneAuthorization" do
    autodns_json(conn, 200, nil)
  end

  get "/job/:id" do
    autodns_json(conn, 200, %{
      "id" => String.to_integer(id),
      "status" => "RUNNING",
      "type" => "DOMAIN_CREATE"
    })
  end

  # =============================================
  # Polls
  # =============================================

  get "/poll" do
    autodns_json(conn, 200, %{
      "id" => 42,
      "owner" => %{"user" => "admin", "context" => 4},
      "job" => %{"id" => 1}
    })
  end

  put "/poll/:id" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # BackupMx
  # =============================================

  post "/backupMx/_search" do
    autodns_list(conn, [%{"domain" => "example.com", "target" => "backup.example.com"}])
  end

  post "/backupMx" do
    autodns_json(conn, 200, Map.merge(%{"domain" => "new.com"}, conn.body_params))
  end

  get "/backupMx/:domain" do
    autodns_json(conn, 200, %{"domain" => domain, "target" => "backup.#{domain}"})
  end

  delete "/backupMx/:domain" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Mail Proxies
  # =============================================

  post "/mailProxy/_search" do
    autodns_list(conn, [%{"domain" => "example.com", "target" => "mail.example.com"}])
  end

  post "/mailProxy" do
    autodns_json(conn, 200, Map.merge(%{"domain" => "new.com"}, conn.body_params))
  end

  get "/mailProxy/:domain" do
    autodns_json(conn, 200, %{"domain" => domain, "target" => "mail.#{domain}"})
  end

  put "/mailProxy/:domain" do
    autodns_json(conn, 200, Map.merge(%{"domain" => domain}, conn.body_params))
  end

  delete "/mailProxy/:domain" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Redirects
  # =============================================

  post "/redirect/_search" do
    autodns_list(conn, [%{"source" => "old.example.com", "target" => "https://new.example.com"}])
  end

  post "/redirect" do
    autodns_json(conn, 200, Map.merge(%{"source" => "created.com"}, conn.body_params))
  end

  get "/redirect/:source" do
    autodns_json(conn, 200, %{"source" => source, "target" => "https://target.com"})
  end

  put "/redirect/:source" do
    autodns_json(conn, 200, Map.merge(%{"source" => source}, conn.body_params))
  end

  delete "/redirect/:source" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Invoices
  # =============================================

  post "/invoice/_search" do
    autodns_list(conn, [%{"id" => 1, "number" => "INV-001", "amount" => 99.99}])
  end

  get "/invoice/:id" do
    autodns_json(conn, 200, %{
      "id" => String.to_integer(id),
      "number" => "INV-001",
      "amount" => 99.99,
      "currency" => "EUR"
    })
  end

  # =============================================
  # Subscriptions
  # =============================================

  post "/subscription/_search" do
    autodns_list(conn, [%{"contractId" => "SUB-001", "status" => "ACTIVE"}])
  end

  post "/subscription" do
    autodns_json(conn, 200, Map.merge(%{"contractId" => "SUB-NEW"}, conn.body_params))
  end

  put "/subscription/:contract_id/_upgrade" do
    autodns_json(conn, 200, %{"contractId" => contract_id, "status" => "UPGRADED"})
  end

  post "/subscription/:contract_id/cancelation" do
    autodns_json(conn, 200, %{"contractId" => contract_id})
  end

  delete "/subscription/:contract_id/cancelation" do
    autodns_json(conn, 200, nil)
  end

  put "/subscription/:contract_id" do
    autodns_json(conn, 200, Map.merge(%{"contractId" => contract_id}, conn.body_params))
  end

  delete "/subscription/:contract_id" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Subject Products
  # =============================================

  post "/subjectProduct/_search" do
    autodns_list(conn, [%{"id" => 1, "name" => "Domain .com", "type" => "DOMAIN"}])
  end

  # =============================================
  # TMCH Marks
  # =============================================

  post "/tmchMark/_search" do
    autodns_list(conn, [%{"reference" => "TMCH-001", "name" => "EXAMPLE"}])
  end

  post "/tmchMark/_import" do
    autodns_json(conn, 200, Map.merge(%{"reference" => "TMCH-IMPORT"}, conn.body_params))
  end

  post "/tmchMark/_transfer" do
    autodns_json(conn, 200, Map.merge(%{"reference" => "TMCH-TRANSFER"}, conn.body_params))
  end

  post "/tmchMark" do
    autodns_json(conn, 200, Map.merge(%{"reference" => "TMCH-NEW"}, conn.body_params))
  end

  post "/tmchMark/claim/_search" do
    autodns_list(conn, [%{"reference" => "CLAIM-001", "domain" => "example.com"}])
  end

  post "/tmchMark/:ref/_confirm" do
    autodns_json(conn, 200, nil)
  end

  get "/tmchMark/claim/:ref" do
    autodns_json(conn, 200, %{"reference" => ref, "domain" => "example.com"})
  end

  post "/tmchMark/claim/:ref/_confirm" do
    autodns_json(conn, 200, nil)
  end

  put "/tmchMark/claim/:ref/_reject" do
    autodns_json(conn, 200, nil)
  end

  put "/tmchMark/:ref/_transfer" do
    autodns_json(conn, 200, %{"reference" => ref})
  end

  post "/tmchMark/:ref/document" do
    autodns_json(conn, 200, conn.body_params)
  end

  get "/tmchMark/:ref/document/:type" do
    autodns_json(conn, 200, %{"reference" => ref, "type" => type})
  end

  put "/tmchMark/:ref/document/:type" do
    autodns_json(conn, 200, %{"reference" => ref, "type" => type})
  end

  delete "/tmchMark/:ref/document/:type" do
    autodns_json(conn, 200, nil)
  end

  get "/tmchMark/:ref" do
    autodns_json(conn, 200, %{"reference" => ref, "name" => "EXAMPLE"})
  end

  put "/tmchMark/:ref" do
    autodns_json(conn, 200, Map.merge(%{"reference" => ref}, conn.body_params))
  end

  delete "/tmchMark/:ref" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Object Assignments
  # =============================================

  put "/object/_assignment/all" do
    autodns_json(conn, 200, nil)
  end

  put "/object/_assignment" do
    autodns_json(conn, 200, nil)
  end

  # =============================================
  # Error simulation endpoints
  # =============================================

  get "/error/401" do
    autodns_error(conn, 401, "Unauthorized")
  end

  get "/error/404" do
    autodns_error(conn, 404, "Not Found")
  end

  get "/error/422" do
    autodns_error(conn, 422, "Validation failed")
  end

  # Catch-all
  match _ do
    autodns_error(conn, 404, "Not found: #{conn.request_path}")
  end
end
