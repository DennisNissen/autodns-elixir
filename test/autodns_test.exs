defmodule AutoDNSTest do
  use ExUnit.Case, async: true

  defp client do
    AutoDNS.Client.new("test-user", "test-password",
      base_url: "",
      plug: AutoDNS.MockServer
    )
  end

  # =============================================
  # AutoDNS (top-level client creation)
  # =============================================

  describe "AutoDNS" do
    test "client/3 creates a client struct" do
      c = AutoDNS.client("myuser", "mypass")
      assert %AutoDNS.Client{username: "myuser", password: "mypass"} = c
      assert c.base_url == "https://api.autodns.com/v1"
    end

    test "client/3 with custom base_url" do
      c = AutoDNS.client("user", "pass", base_url: "http://localhost:4000")
      assert c.base_url == "http://localhost:4000"
    end

    test "client/3 with context" do
      c = AutoDNS.client("user", "pass", context: 4)
      assert c.context == 4
    end

    test "client/3 with demo mode" do
      c = AutoDNS.client("user", "pass", demo: true)
      assert Keyword.get(c.opts, :demo) == true
    end
  end

  # =============================================
  # AutoDNS.Client
  # =============================================

  describe "AutoDNS.Client" do
    test "get/3 performs a GET request" do
      {:ok, response} = AutoDNS.Client.get(client(), "/hello")
      assert response.status == 200
      assert response.stid != nil
    end

    test "post/4 performs a POST request" do
      {:ok, response} = AutoDNS.Client.post(client(), "/domain", %{"name" => "test.com"})
      assert response.status == 200
      assert response.object["name"] != nil
    end

    test "put/4 performs a PUT request" do
      {:ok, response} = AutoDNS.Client.put(client(), "/domain/test.com", %{"comment" => "hi"})
      assert response.status == 200
    end

    test "delete/4 performs a DELETE request" do
      {:ok, response} = AutoDNS.Client.delete(client(), "/zone/test.com")
      assert response.status == 200
    end

    test "patch/4 performs a PATCH request" do
      {:ok, response} =
        AutoDNS.Client.patch(client(), "/zone/test.com/a.ns14.net", %{"comment" => "test"})

      assert response.status == 200
    end

    test "returns error for 4xx responses" do
      {:error, error} = AutoDNS.Client.get(client(), "/error/404")
      assert %AutoDNS.Error{} = error
      assert error.status == 404
      assert error.message == "Not Found"
    end

    test "returns error for 401 unauthorized" do
      {:error, error} = AutoDNS.Client.get(client(), "/error/401")
      assert error.status == 401
      assert error.message == "Unauthorized"
    end

    test "returns error for 422 validation" do
      {:error, error} = AutoDNS.Client.get(client(), "/error/422")
      assert error.status == 422
      assert error.message == "Validation failed"
    end
  end

  # =============================================
  # AutoDNS.Response
  # =============================================

  describe "AutoDNS.Response" do
    test "from_body/3 extracts stid, data, and object" do
      body = %{
        "stid" => "test-stid",
        "status" => %{"type" => "SUCCESS"},
        "object" => %{"name" => "example.com"},
        "data" => [%{"name" => "a.com"}]
      }

      response = AutoDNS.Response.from_body(200, body, [])
      assert response.stid == "test-stid"
      assert response.object == %{"name" => "example.com"}
      assert response.data == [%{"name" => "a.com"}]
    end

    test "from_body/3 handles non-map body" do
      response = AutoDNS.Response.from_body(200, "raw string", [])
      assert response.body == "raw string"
      assert response.stid == nil
    end

    test "to_struct/2 uses data[0] when object is absent" do
      body = %{"stid" => "s", "data" => [%{"origin" => "example.com"}]}
      response = AutoDNS.Response.from_body(200, body, [])
      {:ok, zone} = AutoDNS.Response.to_struct({:ok, response}, AutoDNS.Zone)
      assert zone.origin == "example.com"
    end

    test "to_struct/2 prefers data[0] over object reference stub" do
      body = %{
        "stid" => "s",
        "object" => %{"type" => "Zone", "value" => "example.com"},
        "data" => [
          %{
            "origin" => "example.com",
            "resourceRecords" => [
              %{"name" => "www", "type" => "A", "value" => "1.2.3.4"}
            ]
          }
        ]
      }

      response = AutoDNS.Response.from_body(200, body, [])
      {:ok, zone} = AutoDNS.Response.to_struct({:ok, response}, AutoDNS.Zone)
      assert zone.origin == "example.com"
      assert [record | _] = zone.resourceRecords
      assert is_map(record)
    end

    test "object/1 prefers data[0], then object, then body" do
      data = AutoDNS.Response.from_body(200, %{"data" => [%{"k" => "d"}]}, [])
      assert AutoDNS.Response.object({:ok, data}) == {:ok, %{"k" => "d"}}

      obj = AutoDNS.Response.from_body(200, %{"object" => %{"k" => "o"}}, [])
      assert AutoDNS.Response.object({:ok, obj}) == {:ok, %{"k" => "o"}}

      both =
        AutoDNS.Response.from_body(
          200,
          %{"object" => %{"k" => "o"}, "data" => [%{"k" => "d"}]},
          []
        )

      assert AutoDNS.Response.object({:ok, both}) == {:ok, %{"k" => "d"}}

      raw = AutoDNS.Response.from_body(200, %{"k" => "b"}, [])
      assert AutoDNS.Response.object({:ok, raw}) == {:ok, %{"k" => "b"}}
    end
  end

  # =============================================
  # AutoDNS.Error
  # =============================================

  describe "AutoDNS.Error" do
    test "from_response/1 extracts message from messages array" do
      error =
        AutoDNS.Error.from_response(%{
          status: 400,
          body: %{"messages" => [%{"text" => "Bad request"}]}
        })

      assert error.message == "Bad request"
      assert error.status == 400
    end

    test "from_response/1 extracts message from status.text" do
      error =
        AutoDNS.Error.from_response(%{
          status: 500,
          body: %{"status" => %{"text" => "Server error"}}
        })

      assert error.message == "Server error"
    end

    test "from_response/1 falls back to HTTP status" do
      error = AutoDNS.Error.from_response(%{status: 503, body: %{}})
      assert error.message == "HTTP 503"
    end

    test "from_exception/1 wraps exceptions" do
      error = AutoDNS.Error.from_exception(%RuntimeError{message: "boom"})
      assert error.message == "boom"
      assert error.status == nil
    end

    test "implements Exception behaviour" do
      error = %AutoDNS.Error{message: "test error", status: 400}
      assert Exception.message(error) == "test error"
    end
  end

  # =============================================
  # AutoDNS.Schema
  # =============================================

  describe "AutoDNS.Schema" do
    test "from_map/1 converts string keys to atoms" do
      domain = AutoDNS.Domain.from_map(%{"name" => "example.com", "registryStatus" => "ACTIVE"})
      assert %AutoDNS.Domain{} = domain
      assert domain.name == "example.com"
      assert domain.registryStatus == "ACTIVE"
    end

    test "from_map/1 handles nil" do
      assert AutoDNS.Domain.from_map(nil) == nil
    end

    test "from_list/1 converts a list of maps" do
      domains =
        AutoDNS.Domain.from_list([
          %{"name" => "a.com"},
          %{"name" => "b.com"}
        ])

      assert length(domains) == 2
      assert hd(domains).name == "a.com"
    end

    test "atomize_keys/1 recursively atomizes nested maps" do
      result =
        AutoDNS.Schema.atomize_keys(%{
          "outer" => %{"inner" => "value"},
          "list" => [%{"nested" => true}]
        })

      assert result.outer.inner == "value"
      assert hd(result.list).nested == true
    end
  end

  # =============================================
  # AutoDNS.Hello
  # =============================================

  describe "AutoDNS.Hello" do
    test "hello/1 performs health check" do
      {:ok, body} = AutoDNS.Hello.hello(client())
      assert body["object"]["message"] == "Hello, World!"
    end
  end

  # =============================================
  # AutoDNS.Session
  # =============================================

  describe "AutoDNS.Session" do
    test "login/1 creates a session" do
      {:ok, session} = AutoDNS.Session.login(client())
      assert %AutoDNS.AuthSession{} = session
      assert session.session == "sess-abc-123"
    end

    test "logout/1 ends the session via GET" do
      assert :ok = AutoDNS.Session.logout(client())
    end

    test "delete/1 ends the session via DELETE" do
      assert :ok = AutoDNS.Session.delete(client())
    end
  end

  # =============================================
  # AutoDNS.Account
  # =============================================

  describe "AutoDNS.Account" do
    test "info/1 returns account data" do
      {:ok, account} = AutoDNS.Account.info(client())
      assert %AutoDNS.AccountData{} = account
      assert account.currency == "EUR"
    end

    test "update/2 updates account settings" do
      {:ok, result} = AutoDNS.Account.update(client(), %{"notifications" => true})
      assert is_map(result)
    end
  end

  # =============================================
  # AutoDNS.OTPAuth
  # =============================================

  describe "AutoDNS.OTPAuth" do
    test "get/1 returns OTP configuration" do
      {:ok, otp} = AutoDNS.OTPAuth.get(client())
      assert %AutoDNS.OTPAuthData{} = otp
      assert otp.protocol == "TOTP"
    end

    test "create/1 creates a temporary OTP token" do
      {:ok, otp} = AutoDNS.OTPAuth.create(client())
      assert %AutoDNS.OTPAuthData{} = otp
      assert otp.secret == "JBSWY3DPEHPK3PXP"
    end
  end

  # =============================================
  # AutoDNS.Domains
  # =============================================

  describe "AutoDNS.Domains" do
    test "list/2 searches for domains" do
      {:ok, domains} = AutoDNS.Domains.list(client())
      assert is_list(domains)
      assert length(domains) == 2
      assert hd(domains).name == "example.com"
    end

    test "get/2 fetches a domain by name" do
      {:ok, domain} = AutoDNS.Domains.get(client(), "example.com")
      assert %AutoDNS.Domain{} = domain
      assert domain.name == "example.com"
      assert domain.registryStatus == "ACTIVE"
    end

    test "create/2 registers a new domain" do
      {:ok, domain} = AutoDNS.Domains.create(client(), %{"name" => "new.com"})
      assert %AutoDNS.Domain{} = domain
    end

    test "update/3 updates a domain" do
      {:ok, domain} = AutoDNS.Domains.update(client(), "example.com", %{"comment" => "updated"})
      assert %AutoDNS.Domain{} = domain
      assert domain.name == "example.com"
    end

    test "transfer/2 transfers a domain" do
      {:ok, domain} =
        AutoDNS.Domains.transfer(client(), %{"name" => "transfer.com", "authinfo" => "abc"})

      assert %AutoDNS.Domain{} = domain
    end

    test "trade/2 initiates a domain trade" do
      {:ok, domain} = AutoDNS.Domains.trade(client(), %{"name" => "trade.com"})
      assert %AutoDNS.Domain{} = domain
    end

    test "buy/2 buys a domain" do
      {:ok, domain} = AutoDNS.Domains.buy(client(), %{"name" => "buy.com"})
      assert %AutoDNS.Domain{} = domain
    end

    test "owner_change/2 changes domain owner" do
      {:ok, domain} = AutoDNS.Domains.owner_change(client(), %{"name" => "change.com"})
      assert %AutoDNS.Domain{} = domain
    end

    test "renew/2 renews a domain" do
      {:ok, domain} = AutoDNS.Domains.renew(client(), "example.com")
      assert %AutoDNS.Domain{} = domain
    end

    test "restore/2 restores a domain" do
      {:ok, domain} = AutoDNS.Domains.restore(client(), "example.com")
      assert %AutoDNS.Domain{} = domain
    end

    test "restore_list/1 lists domains pending restore" do
      {:ok, domains} = AutoDNS.Domains.restore_list(client())
      assert is_list(domains)
    end

    test "auto_delete_list/1 lists domains pending auto-deletion" do
      {:ok, results} = AutoDNS.Domains.auto_delete_list(client())
      assert is_list(results)
    end

    test "create_authinfo1/2 creates AuthInfo1" do
      {:ok, result} = AutoDNS.Domains.create_authinfo1(client(), "example.com")
      assert result["authinfo"] == "auth-code-123"
    end

    test "delete_authinfo1/2 deletes AuthInfo1" do
      {:ok, _} = AutoDNS.Domains.delete_authinfo1(client(), "example.com")
    end

    test "create_authinfo2/2 creates AuthInfo2" do
      {:ok, result} = AutoDNS.Domains.create_authinfo2(client(), "example.com")
      assert result["authinfo"] == "auth2-code-456"
    end

    test "update_dnssec/3 updates DNSSEC" do
      {:ok, domain} = AutoDNS.Domains.update_dnssec(client(), "example.com", %{"dnssec" => true})
      assert %AutoDNS.Domain{} = domain
    end

    test "auto_dnssec_key_rollover/2 triggers key rollover" do
      {:ok, domain} = AutoDNS.Domains.auto_dnssec_key_rollover(client(), "example.com")
      assert %AutoDNS.Domain{} = domain
    end

    test "update_comment/3 updates domain comment" do
      {:ok, _} = AutoDNS.Domains.update_comment(client(), "example.com", %{"comment" => "test"})
    end

    test "update_status/3 updates domain status" do
      {:ok, domain} =
        AutoDNS.Domains.update_status(client(), "example.com", %{"status" => "HOLD"})

      assert %AutoDNS.Domain{} = domain
    end

    test "add_domain_safe/2 adds domain to DomainSafe" do
      {:ok, _} = AutoDNS.Domains.add_domain_safe(client(), "example.com")
    end

    test "delete_domain_safe/2 removes domain from DomainSafe" do
      {:ok, _} = AutoDNS.Domains.delete_domain_safe(client(), "example.com")
    end

    test "update_services/2 updates domain services" do
      {:ok, _} = AutoDNS.Domains.update_services(client(), %{"services" => []})
    end

    test "send_authinfo_to_ownerc/2 sends authinfo to owner" do
      {:ok, _} = AutoDNS.Domains.send_authinfo_to_ownerc(client(), "example.com")
    end
  end

  # =============================================
  # AutoDNS.DomainCancelations
  # =============================================

  describe "AutoDNS.DomainCancelations" do
    test "create/3 creates a cancelation" do
      {:ok, cancelation} =
        AutoDNS.DomainCancelations.create(client(), "example.com", %{"type" => "DELETE"})

      assert %AutoDNS.DomainCancelation{} = cancelation
    end

    test "list/1 searches cancelations" do
      {:ok, cancelations} = AutoDNS.DomainCancelations.list(client())
      assert is_list(cancelations)
      assert length(cancelations) > 0
    end

    test "get/2 gets a cancelation" do
      {:ok, cancelation} = AutoDNS.DomainCancelations.get(client(), "example.com")
      assert %AutoDNS.DomainCancelation{} = cancelation
      assert cancelation.type == "DELETE"
    end

    test "update/3 updates a cancelation" do
      {:ok, cancelation} =
        AutoDNS.DomainCancelations.update(client(), "example.com", %{"type" => "EXPIRE"})

      assert %AutoDNS.DomainCancelation{} = cancelation
    end

    test "delete/2 deletes a cancelation" do
      {:ok, _} = AutoDNS.DomainCancelations.delete(client(), "example.com")
    end
  end

  # =============================================
  # AutoDNS.DomainPreregs
  # =============================================

  describe "AutoDNS.DomainPreregs" do
    test "create/2 creates a pre-registration" do
      {:ok, prereg} = AutoDNS.DomainPreregs.create(client(), %{"name" => "test.new"})
      assert %AutoDNS.DomainPrereg{} = prereg
    end

    test "create_and_confirm/2 creates and confirms" do
      {:ok, prereg} = AutoDNS.DomainPreregs.create_and_confirm(client(), %{"name" => "test.new"})
      assert %AutoDNS.DomainPrereg{} = prereg
    end

    test "list/1 searches pre-registrations" do
      {:ok, preregs} = AutoDNS.DomainPreregs.list(client())
      assert is_list(preregs)
    end

    test "get/2 gets a pre-registration" do
      {:ok, prereg} = AutoDNS.DomainPreregs.get(client(), "prereg-1")
      assert %AutoDNS.DomainPrereg{} = prereg
    end

    test "update/3 updates a pre-registration" do
      {:ok, prereg} = AutoDNS.DomainPreregs.update(client(), "prereg-1", %{"name" => "updated"})
      assert %AutoDNS.DomainPrereg{} = prereg
    end

    test "delete/2 deletes a pre-registration" do
      {:ok, _} = AutoDNS.DomainPreregs.delete(client(), "prereg-1")
    end

    test "confirm/2 confirms a pre-registration" do
      {:ok, prereg} = AutoDNS.DomainPreregs.confirm(client(), "prereg-1")
      assert %AutoDNS.DomainPrereg{} = prereg
    end
  end

  # =============================================
  # AutoDNS.DomainPremiums
  # =============================================

  describe "AutoDNS.DomainPremiums" do
    test "get/2 returns premium domain info" do
      {:ok, result} = AutoDNS.DomainPremiums.get(client(), "premium.com")
      assert result["name"] == "premium.com"
    end
  end

  # =============================================
  # AutoDNS.DomainStudio
  # =============================================

  describe "AutoDNS.DomainStudio" do
    test "search/2 searches for available domains" do
      {:ok, result} = AutoDNS.DomainStudio.search(client(), %{"searchToken" => "example"})
      assert result["results"] != nil
    end

    test "classify/2 classifies domains" do
      {:ok, result} = AutoDNS.DomainStudio.classify(client(), %{"domains" => ["example.com"]})
      assert is_map(result)
    end

    test "social_media_check/2 checks social media" do
      {:ok, result} = AutoDNS.DomainStudio.social_media_check(client(), %{"name" => "example"})
      assert is_map(result)
    end

    test "tlds/1 lists available TLDs" do
      {:ok, tlds} = AutoDNS.DomainStudio.tlds(client())
      assert is_list(tlds)
    end

    test "tld_statistics/1 gets TLD stats" do
      {:ok, result} = AutoDNS.DomainStudio.tld_statistics(client())
      assert is_map(result)
    end
  end

  # =============================================
  # AutoDNS.DomainSafe
  # =============================================

  describe "AutoDNS.DomainSafe" do
    test "create_contact/2 creates a safe contact" do
      {:ok, result} = AutoDNS.DomainSafe.create_contact(client(), %{"name" => "Test"})
      assert is_map(result)
    end

    test "list_contacts/1 lists safe contacts" do
      {:ok, results} = AutoDNS.DomainSafe.list_contacts(client())
      assert is_list(results)
    end

    test "get_contact/2 gets a safe contact" do
      {:ok, result} = AutoDNS.DomainSafe.get_contact(client(), 1)
      assert result["id"] == 1
    end

    test "update_contact/3 updates a safe contact" do
      {:ok, result} = AutoDNS.DomainSafe.update_contact(client(), 1, %{"name" => "Updated"})
      assert result["id"] == 1
    end

    test "create_user/2 creates a safe user" do
      {:ok, result} = AutoDNS.DomainSafe.create_user(client(), %{"user" => "safeuser"})
      assert is_map(result)
    end

    test "update_user/2 updates a safe user" do
      {:ok, result} = AutoDNS.DomainSafe.update_user(client(), %{"user" => "safeuser"})
      assert is_map(result)
    end

    test "delete_user/3 deletes a safe user" do
      {:ok, _} = AutoDNS.DomainSafe.delete_user(client(), "safeuser", 4)
    end

    test "create_object/2 creates a safe object" do
      {:ok, result} =
        AutoDNS.DomainSafe.create_object(client(), %{"type" => "DOMAIN", "value" => "test.com"})

      assert is_map(result)
    end

    test "list_objects/1 lists safe objects" do
      {:ok, results} = AutoDNS.DomainSafe.list_objects(client())
      assert is_list(results)
    end

    test "delete_object/3 deletes a safe object" do
      {:ok, _} = AutoDNS.DomainSafe.delete_object(client(), "example.com", "DOMAIN")
    end
  end

  # =============================================
  # AutoDNS.TransferOuts
  # =============================================

  describe "AutoDNS.TransferOuts" do
    test "list/1 searches outgoing transfers" do
      {:ok, transfers} = AutoDNS.TransferOuts.list(client())
      assert is_list(transfers)
      assert hd(transfers).domain == "transfer.com"
    end

    test "get/2 gets an outgoing transfer" do
      {:ok, transfer} = AutoDNS.TransferOuts.get(client(), "transfer.com")
      assert %AutoDNS.TransferOut{} = transfer
      assert transfer.domain == "transfer.com"
    end

    test "answer/3 answers a transfer" do
      {:ok, _} = AutoDNS.TransferOuts.answer(client(), "transfer.com", "ACK")
    end
  end

  # =============================================
  # AutoDNS.Zones
  # =============================================

  describe "AutoDNS.Zones" do
    test "create/2 creates a new zone" do
      {:ok, zone} = AutoDNS.Zones.create(client(), %{"origin" => "example.com"})
      assert %AutoDNS.Zone{} = zone
    end

    test "list/1 searches for zones" do
      {:ok, zones} = AutoDNS.Zones.list(client())
      assert is_list(zones)
      assert length(zones) == 2
    end

    test "get/2 gets a zone by name" do
      {:ok, zone} = AutoDNS.Zones.get(client(), "example.com")
      assert %AutoDNS.Zone{} = zone
      assert zone.origin == "example.com"
      assert [record | _] = zone.resourceRecords
      assert is_map(record)
    end

    test "get/3 gets a zone by name and VNS" do
      {:ok, zone} = AutoDNS.Zones.get(client(), "example.com", "a.ns14.net")
      assert %AutoDNS.Zone{} = zone
      assert zone.virtualNameServer == "a.ns14.net"
    end

    test "update/3 updates a zone" do
      {:ok, zone} = AutoDNS.Zones.update(client(), "example.com", %{"comment" => "updated"})

      assert %AutoDNS.Zone{} = zone
    end

    test "update/4 updates a zone with VNS" do
      {:ok, zone} =
        AutoDNS.Zones.update(client(), "example.com", "a.ns14.net", %{"comment" => "updated"})

      assert %AutoDNS.Zone{} = zone
    end

    test "delete/2 deletes a zone" do
      {:ok, _} = AutoDNS.Zones.delete(client(), "example.com")
    end

    test "delete/3 deletes a zone with VNS" do
      {:ok, _} = AutoDNS.Zones.delete(client(), "example.com", "a.ns14.net")
    end

    test "patch/4 patches a zone" do
      {:ok, zone} =
        AutoDNS.Zones.patch(client(), "example.com", "a.ns14.net", %{"comment" => "patched"})

      assert %AutoDNS.Zone{} = zone
    end

    test "stream/4 streams zone updates" do
      {:ok, _} = AutoDNS.Zones.stream(client(), "example.com", "a.ns14.net", %{})
    end

    test "import_zone/4 imports a zone" do
      {:ok, zone} = AutoDNS.Zones.import_zone(client(), "example.com", "a.ns14.net", %{})
      assert %AutoDNS.Zone{} = zone
    end

    test "axfr/3 performs zone transfer" do
      {:ok, zone} = AutoDNS.Zones.axfr(client(), "example.com", "a.ns14.net")
      assert %AutoDNS.Zone{} = zone
    end

    test "copy/4 copies a zone" do
      {:ok, zone} =
        AutoDNS.Zones.copy(client(), "example.com", "a.ns14.net", %{"target" => "copy.com"})

      assert %AutoDNS.Zone{} = zone
    end

    test "migrate/4 migrates a zone" do
      {:ok, zone} = AutoDNS.Zones.migrate(client(), "example.com", "a.ns14.net", %{})
      assert %AutoDNS.Zone{} = zone
    end

    test "restore/3 restores a zone" do
      {:ok, zone} = AutoDNS.Zones.restore(client(), "example.com", "a.ns14.net")
      assert %AutoDNS.Zone{} = zone
    end

    test "update_comment/4 updates zone comment" do
      {:ok, _} =
        AutoDNS.Zones.update_comment(client(), "example.com", "a.ns14.net", %{
          "comment" => "test"
        })
    end

    test "add_domain_safe/3 adds zone to DomainSafe" do
      {:ok, _} = AutoDNS.Zones.add_domain_safe(client(), "example.com", "a.ns14.net")
    end

    test "delete_domain_safe/3 removes zone from DomainSafe" do
      {:ok, _} = AutoDNS.Zones.delete_domain_safe(client(), "example.com", "a.ns14.net")
    end

    test "history_list/1 lists zone history" do
      {:ok, history} = AutoDNS.Zones.history_list(client())
      assert is_list(history)
    end

    test "history_get/2 gets a zone history entry" do
      {:ok, entry} = AutoDNS.Zones.history_get(client(), 1)
      assert entry["logId"] == 1
    end
  end

  # =============================================
  # AutoDNS.ZoneQueries
  # =============================================

  describe "AutoDNS.ZoneQueries" do
    test "list/1 searches zone queries" do
      {:ok, results} = AutoDNS.ZoneQueries.list(client())
      assert is_list(results)
    end

    test "base_list/4 searches zone-specific queries" do
      {:ok, results} = AutoDNS.ZoneQueries.base_list(client(), "example.com", "a.ns14.net")
      assert is_list(results)
    end
  end

  # =============================================
  # AutoDNS.Contacts
  # =============================================

  describe "AutoDNS.Contacts" do
    test "create/2 creates a contact" do
      {:ok, contact} = AutoDNS.Contacts.create(client(), %{"fname" => "John", "lname" => "Doe"})

      assert %AutoDNS.Contact{} = contact
    end

    test "list/1 searches for contacts" do
      {:ok, contacts} = AutoDNS.Contacts.list(client())
      assert is_list(contacts)
      assert length(contacts) == 2
    end

    test "get/2 gets a contact by ID" do
      {:ok, contact} = AutoDNS.Contacts.get(client(), 1)
      assert %AutoDNS.Contact{} = contact
      assert contact.fname == "John"
    end

    test "update/3 updates a contact" do
      {:ok, contact} = AutoDNS.Contacts.update(client(), 1, %{"fname" => "Jane"})
      assert %AutoDNS.Contact{} = contact
    end

    test "delete/2 deletes a contact" do
      {:ok, _} = AutoDNS.Contacts.delete(client(), 1)
    end

    test "update_comment/3 updates contact comment" do
      {:ok, _} = AutoDNS.Contacts.update_comment(client(), 1, %{"comment" => "test"})
    end

    test "add_domain_safe/2 adds contact to DomainSafe" do
      {:ok, _} = AutoDNS.Contacts.add_domain_safe(client(), 1)
    end

    test "delete_domain_safe/2 removes contact from DomainSafe" do
      {:ok, _} = AutoDNS.Contacts.delete_domain_safe(client(), 1)
    end

    test "restore/2 restores a contact" do
      {:ok, _} = AutoDNS.Contacts.restore(client(), 1)
    end

    test "get_verification/2 gets contact verification" do
      {:ok, result} = AutoDNS.Contacts.get_verification(client(), 1)
      assert result["status"] == "PENDING"
    end

    test "create_verification/2 creates contact verification" do
      {:ok, result} = AutoDNS.Contacts.create_verification(client(), 1)
      assert is_map(result)
    end

    test "resend_verification_email/2 resends verification" do
      {:ok, _} = AutoDNS.Contacts.resend_verification_email(client(), 1)
    end

    test "verification_info/1 gets verification info" do
      {:ok, result} = AutoDNS.Contacts.verification_info(client())
      assert is_map(result)
    end

    test "confirm_verification/2 confirms verification" do
      {:ok, _} = AutoDNS.Contacts.confirm_verification(client(), %{"token" => "abc"})
    end

    test "list_verifications/1 lists verifications" do
      {:ok, results} = AutoDNS.Contacts.list_verifications(client())
      assert is_list(results)
    end

    test "list_verification_history/1 lists verification history" do
      {:ok, results} = AutoDNS.Contacts.list_verification_history(client())
      assert is_list(results)
    end

    test "verification_history_info/1 gets verification history info" do
      {:ok, result} = AutoDNS.Contacts.verification_history_info(client())
      assert is_map(result)
    end
  end

  # =============================================
  # AutoDNS.ContactDocuments
  # =============================================

  describe "AutoDNS.ContactDocuments" do
    test "create/4 creates a document" do
      {:ok, result} =
        AutoDNS.ContactDocuments.create(client(), 1, "ID_CARD", %{"data" => "base64..."})

      assert result["type"] == "ID_CARD"
    end

    test "get/3 gets a document" do
      {:ok, result} = AutoDNS.ContactDocuments.get(client(), 1, "ID_CARD")
      assert result["type"] == "ID_CARD"
    end

    test "patch/4 patches a document" do
      {:ok, result} =
        AutoDNS.ContactDocuments.patch(client(), 1, "ID_CARD", %{"status" => "APPROVED"})

      assert result["type"] == "ID_CARD"
    end

    test "delete/3 deletes a document" do
      {:ok, _} = AutoDNS.ContactDocuments.delete(client(), 1, "ID_CARD")
    end

    test "copy/3 copies a document" do
      {:ok, result} = AutoDNS.ContactDocuments.copy(client(), 1, "ID_CARD")
      assert result["type"] == "ID_CARD"
    end
  end

  # =============================================
  # AutoDNS.Certificates
  # =============================================

  describe "AutoDNS.Certificates" do
    test "create/2 creates a certificate" do
      {:ok, cert} =
        AutoDNS.Certificates.create(client(), %{"name" => "example.com", "product" => "SSL"})

      assert %AutoDNS.Certificate{} = cert
    end

    test "create_realtime/2 creates a realtime certificate" do
      {:ok, cert} = AutoDNS.Certificates.create_realtime(client(), %{"name" => "example.com"})
      assert %AutoDNS.Certificate{} = cert
    end

    test "prepare_order/2 prepares a certificate order" do
      {:ok, result} = AutoDNS.Certificates.prepare_order(client(), %{"name" => "example.com"})
      assert result["approverEmails"] != nil
    end

    test "list/1 searches for certificates" do
      {:ok, certs} = AutoDNS.Certificates.list(client())
      assert is_list(certs)
      assert length(certs) == 2
    end

    test "get/2 gets a certificate by ID" do
      {:ok, cert} = AutoDNS.Certificates.get(client(), 1)
      assert %AutoDNS.Certificate{} = cert
      assert cert.status == "ISSUED"
    end

    test "delete/2 cancels a certificate" do
      {:ok, _} = AutoDNS.Certificates.delete(client(), 1)
    end

    test "reissue/3 reissues a certificate" do
      {:ok, cert} = AutoDNS.Certificates.reissue(client(), 1, %{"csr" => "new-csr"})
      assert %AutoDNS.Certificate{} = cert
    end

    test "renew/2 renews a certificate" do
      {:ok, cert} = AutoDNS.Certificates.renew(client(), 1)
      assert %AutoDNS.Certificate{} = cert
    end

    test "revoke/2 revokes a certificate" do
      {:ok, _} = AutoDNS.Certificates.revoke(client(), 1)
    end

    test "update_comment/3 updates certificate comment" do
      {:ok, _} = AutoDNS.Certificates.update_comment(client(), 1, %{"comment" => "test"})
    end

    test "site_seal/2 gets site seal" do
      {:ok, result} = AutoDNS.Certificates.site_seal(client(), 1)
      assert result["html"] != nil
    end

    test "install_check/2 runs installation check" do
      {:ok, result} = AutoDNS.Certificates.install_check(client(), %{"hostname" => "example.com"})
      assert result["valid"] == true
    end

    test "check_vmc_data/2 checks VMC data" do
      {:ok, result} = AutoDNS.Certificates.check_vmc_data(client(), %{})
      assert result["valid"] == true
    end
  end

  # =============================================
  # AutoDNS.SslContacts
  # =============================================

  describe "AutoDNS.SslContacts" do
    test "create/2 creates an SSL contact" do
      {:ok, contact} =
        AutoDNS.SslContacts.create(client(), %{"fname" => "John", "lname" => "Doe"})

      assert %AutoDNS.SslContact{} = contact
    end

    test "list/1 searches for SSL contacts" do
      {:ok, contacts} = AutoDNS.SslContacts.list(client())
      assert is_list(contacts)
    end

    test "get/2 gets an SSL contact" do
      {:ok, contact} = AutoDNS.SslContacts.get(client(), 1)
      assert %AutoDNS.SslContact{} = contact
      assert contact.fname == "John"
    end

    test "update/3 updates an SSL contact" do
      {:ok, contact} = AutoDNS.SslContacts.update(client(), 1, %{"fname" => "Jane"})
      assert %AutoDNS.SslContact{} = contact
    end

    test "delete/2 deletes an SSL contact" do
      {:ok, _} = AutoDNS.SslContacts.delete(client(), 1)
    end
  end

  # =============================================
  # AutoDNS.Users
  # =============================================

  describe "AutoDNS.Users" do
    test "create/2 creates a user" do
      {:ok, user} = AutoDNS.Users.create(client(), %{"user" => "newuser", "context" => 4})
      assert %AutoDNS.User{} = user
    end

    test "list/1 searches for users" do
      {:ok, users} = AutoDNS.Users.list(client())
      assert is_list(users)
    end

    test "get/3 gets a user by name and context" do
      {:ok, user} = AutoDNS.Users.get(client(), "admin", 4)
      assert %AutoDNS.User{} = user
      assert user.user == "admin"
      assert user.context == 4
    end

    test "update/4 updates a user" do
      {:ok, user} = AutoDNS.Users.update(client(), "admin", 4, %{"language" => "de"})
      assert %AutoDNS.User{} = user
    end

    test "delete/3 deletes a user" do
      {:ok, _} = AutoDNS.Users.delete(client(), "admin", 4)
    end

    test "lock/3 locks a user" do
      {:ok, _} = AutoDNS.Users.lock(client(), "admin", 4)
    end

    test "unlock/3 unlocks a user" do
      {:ok, _} = AutoDNS.Users.unlock(client(), "admin", 4)
    end

    test "resend_invite/3 resends invitation" do
      {:ok, _} = AutoDNS.Users.resend_invite(client(), "admin", 4)
    end

    test "get_acl/3 gets user ACL" do
      {:ok, result} = AutoDNS.Users.get_acl(client(), "admin", 4)
      assert result["user"] == "admin"
    end

    test "update_acl/4 updates user ACL" do
      {:ok, _} = AutoDNS.Users.update_acl(client(), "admin", 4, %{"acls" => []})
    end

    test "get_profile/3 gets user profile" do
      {:ok, result} = AutoDNS.Users.get_profile(client(), "admin", 4)
      assert result["user"] == "admin"
    end

    test "update_profile/4 updates user profile" do
      {:ok, _} = AutoDNS.Users.update_profile(client(), "admin", 4, %{"language" => "de"})
    end

    test "get_profile_with_prefix/4 gets profile with prefix" do
      {:ok, result} = AutoDNS.Users.get_profile_with_prefix(client(), "admin", 4, "dns")
      assert result["prefix"] == "dns"
    end

    test "update_service_profile/4 updates service profile" do
      {:ok, _} = AutoDNS.Users.update_service_profile(client(), "admin", 4, %{})
    end

    test "create_sso/3 creates SSO" do
      {:ok, result} = AutoDNS.Users.create_sso(client(), "admin", 4)
      assert result["token"] == "sso-token-123"
    end

    test "copy/3 copies a user" do
      {:ok, user} = AutoDNS.Users.copy(client(), "admin", 4)
      assert %AutoDNS.User{} = user
    end

    test "create_verification/3 creates user verification" do
      {:ok, result} = AutoDNS.Users.create_verification(client(), "admin", 4)
      assert is_map(result)
    end

    test "billing_limit/1 gets billing limit" do
      {:ok, result} = AutoDNS.Users.billing_limit(client())
      assert result["limit"] == 10000
    end

    test "billing_term/1 gets billing term" do
      {:ok, result} = AutoDNS.Users.billing_term(client())
      assert result["term"] == "NET30"
    end

    test "task_limit/1 gets task limit" do
      {:ok, result} = AutoDNS.Users.task_limit(client())
      assert result["limit"] == 500
    end

    test "sales_report_list/1 lists sales reports" do
      {:ok, results} = AutoDNS.Users.sales_report_list(client())
      assert is_list(results)
    end
  end

  # =============================================
  # AutoDNS.Jobs
  # =============================================

  describe "AutoDNS.Jobs" do
    test "list/1 searches for jobs" do
      {:ok, jobs} = AutoDNS.Jobs.list(client())
      assert is_list(jobs)
      assert length(jobs) == 2
    end

    test "get/2 gets a job by ID" do
      {:ok, job} = AutoDNS.Jobs.get(client(), 1)
      assert %AutoDNS.Job{} = job
      assert job.status == "RUNNING"
    end

    test "cancel/2 cancels a job" do
      {:ok, _} = AutoDNS.Jobs.cancel(client(), 1)
    end

    test "confirm/2 confirms a job" do
      {:ok, _} = AutoDNS.Jobs.confirm(client(), 1)
    end

    test "resend_approver_email/2 resends approver email" do
      {:ok, _} = AutoDNS.Jobs.resend_approver_email(client(), 1)
    end

    test "resend_phone_authorization/2 resends phone auth" do
      {:ok, _} = AutoDNS.Jobs.resend_phone_authorization(client(), 1)
    end

    test "history_list/1 lists job history" do
      {:ok, history} = AutoDNS.Jobs.history_list(client())
      assert is_list(history)
    end

    test "history_get/2 gets a job history entry" do
      {:ok, entry} = AutoDNS.Jobs.history_get(client(), 1)
      assert entry["id"] == 1
    end
  end

  # =============================================
  # AutoDNS.Polls
  # =============================================

  describe "AutoDNS.Polls" do
    test "get/1 gets the oldest unconfirmed poll" do
      {:ok, poll} = AutoDNS.Polls.get(client())
      assert %AutoDNS.Poll{} = poll
      assert poll.id == 42
    end

    test "confirm/2 confirms a poll message" do
      assert :ok = AutoDNS.Polls.confirm(client(), 42)
    end
  end

  # =============================================
  # AutoDNS.BackupMxes
  # =============================================

  describe "AutoDNS.BackupMxes" do
    test "create/2 creates a BackupMx" do
      {:ok, mx} = AutoDNS.BackupMxes.create(client(), %{"domain" => "test.com"})
      assert %AutoDNS.BackupMx{} = mx
    end

    test "list/1 searches BackupMx configurations" do
      {:ok, mxs} = AutoDNS.BackupMxes.list(client())
      assert is_list(mxs)
    end

    test "get/2 gets a BackupMx" do
      {:ok, mx} = AutoDNS.BackupMxes.get(client(), "example.com")
      assert %AutoDNS.BackupMx{} = mx
      assert mx.domain == "example.com"
    end

    test "delete/2 deletes a BackupMx" do
      {:ok, _} = AutoDNS.BackupMxes.delete(client(), "example.com")
    end
  end

  # =============================================
  # AutoDNS.MailProxies
  # =============================================

  describe "AutoDNS.MailProxies" do
    test "create/2 creates a mail proxy" do
      {:ok, proxy} = AutoDNS.MailProxies.create(client(), %{"domain" => "test.com"})
      assert %AutoDNS.MailProxy{} = proxy
    end

    test "list/1 searches mail proxies" do
      {:ok, proxies} = AutoDNS.MailProxies.list(client())
      assert is_list(proxies)
    end

    test "get/2 gets a mail proxy" do
      {:ok, proxy} = AutoDNS.MailProxies.get(client(), "example.com")
      assert %AutoDNS.MailProxy{} = proxy
      assert proxy.domain == "example.com"
    end

    test "update/3 updates a mail proxy" do
      {:ok, proxy} = AutoDNS.MailProxies.update(client(), "example.com", %{"target" => "new.com"})
      assert %AutoDNS.MailProxy{} = proxy
    end

    test "delete/2 deletes a mail proxy" do
      {:ok, _} = AutoDNS.MailProxies.delete(client(), "example.com")
    end
  end

  # =============================================
  # AutoDNS.Redirects
  # =============================================

  describe "AutoDNS.Redirects" do
    test "create/2 creates a redirect" do
      {:ok, redirect} =
        AutoDNS.Redirects.create(client(), %{
          "source" => "old.com",
          "target" => "https://new.com"
        })

      assert %AutoDNS.Redirect{} = redirect
    end

    test "list/1 searches redirects" do
      {:ok, redirects} = AutoDNS.Redirects.list(client())
      assert is_list(redirects)
    end

    test "get/2 gets a redirect" do
      {:ok, redirect} = AutoDNS.Redirects.get(client(), "old.example.com")
      assert %AutoDNS.Redirect{} = redirect
    end

    test "update/3 updates a redirect" do
      {:ok, redirect} =
        AutoDNS.Redirects.update(client(), "old.example.com", %{"target" => "https://new.com"})

      assert %AutoDNS.Redirect{} = redirect
    end

    test "delete/2 deletes a redirect" do
      {:ok, _} = AutoDNS.Redirects.delete(client(), "old.example.com")
    end
  end

  # =============================================
  # AutoDNS.Invoices
  # =============================================

  describe "AutoDNS.Invoices" do
    test "list/1 searches for invoices" do
      {:ok, invoices} = AutoDNS.Invoices.list(client())
      assert is_list(invoices)
    end

    test "get/2 gets an invoice" do
      {:ok, invoice} = AutoDNS.Invoices.get(client(), 1)
      assert %AutoDNS.Invoice{} = invoice
      assert invoice.currency == "EUR"
    end
  end

  # =============================================
  # AutoDNS.Subscriptions
  # =============================================

  describe "AutoDNS.Subscriptions" do
    test "create/2 creates a subscription" do
      {:ok, sub} = AutoDNS.Subscriptions.create(client(), %{"article" => "DOMAIN"})
      assert %AutoDNS.Subscription{} = sub
    end

    test "list/1 searches subscriptions" do
      {:ok, subs} = AutoDNS.Subscriptions.list(client())
      assert is_list(subs)
    end

    test "update/3 updates a subscription" do
      {:ok, sub} = AutoDNS.Subscriptions.update(client(), "SUB-001", %{"status" => "ACTIVE"})
      assert %AutoDNS.Subscription{} = sub
    end

    test "delete/2 deletes a subscription" do
      {:ok, _} = AutoDNS.Subscriptions.delete(client(), "SUB-001")
    end

    test "upgrade/3 upgrades a subscription" do
      {:ok, sub} = AutoDNS.Subscriptions.upgrade(client(), "SUB-001", %{"variant" => "PRO"})
      assert %AutoDNS.Subscription{} = sub
    end

    test "create_cancelation/2 creates cancelation" do
      {:ok, _} = AutoDNS.Subscriptions.create_cancelation(client(), "SUB-001")
    end

    test "delete_cancelation/2 deletes cancelation" do
      {:ok, _} = AutoDNS.Subscriptions.delete_cancelation(client(), "SUB-001")
    end
  end

  # =============================================
  # AutoDNS.SubjectProducts
  # =============================================

  describe "AutoDNS.SubjectProducts" do
    test "list/1 searches subject products" do
      {:ok, products} = AutoDNS.SubjectProducts.list(client())
      assert is_list(products)
      assert hd(products).name == "Domain .com"
    end
  end

  # =============================================
  # AutoDNS.TmchMarks
  # =============================================

  describe "AutoDNS.TmchMarks" do
    test "create/2 creates a TMCH mark" do
      {:ok, mark} = AutoDNS.TmchMarks.create(client(), %{"name" => "EXAMPLE"})
      assert %AutoDNS.TmchMark{} = mark
    end

    test "import_mark/2 imports a TMCH mark" do
      {:ok, mark} = AutoDNS.TmchMarks.import_mark(client(), %{"name" => "IMPORTED"})
      assert %AutoDNS.TmchMark{} = mark
    end

    test "list/1 searches TMCH marks" do
      {:ok, marks} = AutoDNS.TmchMarks.list(client())
      assert is_list(marks)
    end

    test "get/2 gets a TMCH mark" do
      {:ok, mark} = AutoDNS.TmchMarks.get(client(), "TMCH-001")
      assert %AutoDNS.TmchMark{} = mark
    end

    test "update/3 updates a TMCH mark" do
      {:ok, mark} = AutoDNS.TmchMarks.update(client(), "TMCH-001", %{"name" => "UPDATED"})
      assert %AutoDNS.TmchMark{} = mark
    end

    test "delete/2 deletes a TMCH mark" do
      {:ok, _} = AutoDNS.TmchMarks.delete(client(), "TMCH-001")
    end

    test "confirm/2 confirms a TMCH mark" do
      {:ok, _} = AutoDNS.TmchMarks.confirm(client(), "TMCH-001")
    end

    test "transfer/3 transfers a TMCH mark" do
      {:ok, mark} = AutoDNS.TmchMarks.transfer(client(), "TMCH-001", %{"gaining" => "other"})
      assert %AutoDNS.TmchMark{} = mark
    end

    test "import_and_transfer/2 imports and transfers" do
      {:ok, mark} = AutoDNS.TmchMarks.import_and_transfer(client(), %{"name" => "TRANSFER"})
      assert %AutoDNS.TmchMark{} = mark
    end

    test "create_document/3 creates a document" do
      {:ok, result} =
        AutoDNS.TmchMarks.create_document(client(), "TMCH-001", %{"type" => "LICENSE"})

      assert is_map(result)
    end

    test "get_document/3 gets a document" do
      {:ok, result} = AutoDNS.TmchMarks.get_document(client(), "TMCH-001", "LICENSE")
      assert result["type"] == "LICENSE"
    end

    test "upload_document/4 uploads a document" do
      {:ok, result} =
        AutoDNS.TmchMarks.upload_document(client(), "TMCH-001", "LICENSE", %{"data" => "base64"})

      assert result["type"] == "LICENSE"
    end

    test "delete_document/3 deletes a document" do
      {:ok, _} = AutoDNS.TmchMarks.delete_document(client(), "TMCH-001", "LICENSE")
    end
  end

  # =============================================
  # AutoDNS.TmchClaims
  # =============================================

  describe "AutoDNS.TmchClaims" do
    test "list/1 searches TMCH claims" do
      {:ok, claims} = AutoDNS.TmchClaims.list(client())
      assert is_list(claims)
    end

    test "get/2 gets a TMCH claim" do
      {:ok, claim} = AutoDNS.TmchClaims.get(client(), "CLAIM-001")
      assert %AutoDNS.TmchClaim{} = claim
    end

    test "confirm/2 confirms a TMCH claim" do
      {:ok, _} = AutoDNS.TmchClaims.confirm(client(), "CLAIM-001")
    end

    test "reject/2 rejects a TMCH claim" do
      {:ok, _} = AutoDNS.TmchClaims.reject(client(), "CLAIM-001")
    end
  end

  # =============================================
  # AutoDNS.ObjectAssignments
  # =============================================

  describe "AutoDNS.ObjectAssignments" do
    test "assign/2 assigns objects to a user" do
      {:ok, _} =
        AutoDNS.ObjectAssignments.assign(client(), %{
          "objects" => [%{"type" => "DOMAIN", "value" => "example.com"}]
        })
    end

    test "assign_all/2 assigns all objects" do
      {:ok, _} = AutoDNS.ObjectAssignments.assign_all(client(), %{"user" => "admin"})
    end
  end

  # =============================================
  # Schema struct tests
  # =============================================

  describe "Schema structs" do
    test "Domain struct has expected fields" do
      domain = %AutoDNS.Domain{name: "test.com", registryStatus: "ACTIVE"}
      assert domain.name == "test.com"
    end

    test "Zone struct has expected fields" do
      zone = %AutoDNS.Zone{origin: "test.com", virtualNameServer: "a.ns14.net"}
      assert zone.origin == "test.com"
    end

    test "Contact struct has expected fields" do
      contact = %AutoDNS.Contact{fname: "John", lname: "Doe", email: "john@example.com"}
      assert contact.email == "john@example.com"
    end

    test "Certificate struct has expected fields" do
      cert = %AutoDNS.Certificate{id: 1, name: "example.com", status: "ISSUED"}
      assert cert.status == "ISSUED"
    end

    test "User struct has expected fields" do
      user = %AutoDNS.User{user: "admin", context: 4}
      assert user.user == "admin"
    end

    test "Job struct has expected fields" do
      job = %AutoDNS.Job{id: 1, status: "RUNNING", type: "DOMAIN_CREATE"}
      assert job.type == "DOMAIN_CREATE"
    end

    test "SslContact struct has expected fields" do
      contact = %AutoDNS.SslContact{fname: "Jane", email: "jane@example.com"}
      assert contact.fname == "Jane"
    end

    test "BackupMx struct has expected fields" do
      mx = %AutoDNS.BackupMx{domain: "test.com", target: "backup.test.com"}
      assert mx.target == "backup.test.com"
    end

    test "MailProxy struct has expected fields" do
      proxy = %AutoDNS.MailProxy{domain: "test.com", target: "mail.test.com"}
      assert proxy.target == "mail.test.com"
    end

    test "Redirect struct has expected fields" do
      redirect = %AutoDNS.Redirect{source: "old.com", target: "https://new.com"}
      assert redirect.source == "old.com"
    end

    test "DomainCancelation struct has expected fields" do
      cancel = %AutoDNS.DomainCancelation{domain: "test.com", type: "DELETE"}
      assert cancel.type == "DELETE"
    end

    test "DomainPrereg struct has expected fields" do
      prereg = %AutoDNS.DomainPrereg{reference: "REF-1", name: "test.new"}
      assert prereg.reference == "REF-1"
    end

    test "TransferOut struct has expected fields" do
      transfer = %AutoDNS.TransferOut{domain: "test.com", status: "PENDING"}
      assert transfer.status == "PENDING"
    end

    test "Invoice struct has expected fields" do
      invoice = %AutoDNS.Invoice{id: 1, number: "INV-001", currency: "EUR"}
      assert invoice.number == "INV-001"
    end

    test "Subscription struct has expected fields" do
      sub = %AutoDNS.Subscription{contractId: "SUB-001", status: "ACTIVE"}
      assert sub.contractId == "SUB-001"
    end

    test "TmchMark struct has expected fields" do
      mark = %AutoDNS.TmchMark{reference: "TMCH-001", name: "EXAMPLE"}
      assert mark.reference == "TMCH-001"
    end

    test "TmchClaim struct has expected fields" do
      claim = %AutoDNS.TmchClaim{reference: "CLAIM-001", domain: "example.com"}
      assert claim.domain == "example.com"
    end

    test "Poll struct has expected fields" do
      poll = %AutoDNS.Poll{id: 42, stid: "test-stid"}
      assert poll.id == 42
    end

    test "AuthSession struct has expected fields" do
      session = %AutoDNS.AuthSession{session: "abc", user: "admin"}
      assert session.session == "abc"
    end

    test "OTPAuthData struct has expected fields" do
      otp = %AutoDNS.OTPAuthData{protocol: "TOTP", digits: 6}
      assert otp.protocol == "TOTP"
    end

    test "SubjectProduct struct has expected fields" do
      product = %AutoDNS.SubjectProduct{id: 1, name: "Domain .com"}
      assert product.name == "Domain .com"
    end

    test "AccountData struct has expected fields" do
      account = %AutoDNS.AccountData{currency: "EUR", currentAccountBalance: 1000.0}
      assert account.currency == "EUR"
    end
  end
end
