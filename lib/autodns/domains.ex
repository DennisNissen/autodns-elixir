defmodule AutoDNS.Domains do
  @moduledoc """
  Operations on AutoDNS Domains.

  Domains are the central resource in AutoDNS. This module provides full CRUD
  operations plus domain-specific actions like transfer, restore, trade, and more.

  ## Listing Domains

      {:ok, domains} = AutoDNS.Domains.list(client, %{
        "filters" => [%{"key" => "name", "value" => "example*", "operator" => "LIKE"}],
        "view" => %{"limit" => 10, "offset" => 0}
      })

  ## Getting a Domain

      {:ok, domain} = AutoDNS.Domains.get(client, "example.com")

  ## Creating a Domain

      {:ok, domain} = AutoDNS.Domains.create(client, %{
        "name" => "example.com",
        "nameServers" => [%{"name" => "ns1.example.com"}, %{"name" => "ns2.example.com"}],
        "ownerc" => %{"fname" => "John", "lname" => "Doe", "email" => "john@example.com"}
      })

  ## Transferring a Domain

      {:ok, domain} = AutoDNS.Domains.transfer(client, %{
        "name" => "example.com",
        "authinfo" => "transfer-auth-code"
      })

  """

  alias AutoDNS.{Client, Domain, Response}

  @base_path "/domain"

  @doc "Creates a new domain registration."
  @spec create(Client.t(), map()) :: {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(Domain)
  end

  @doc "Searches for domains using a query object."
  @spec list(Client.t(), map()) :: {:ok, [Domain.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Domain)
  end

  @doc "Gets a single domain by name."
  @spec get(Client.t(), String.t()) :: {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    Client.get(client, "#{@base_path}/#{name}") |> Response.to_struct(Domain)
  end

  @doc "Updates an existing domain."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, attrs) do
    Client.put(client, "#{@base_path}/#{name}", attrs) |> Response.to_struct(Domain)
  end

  @doc "Transfers a domain."
  @spec transfer(Client.t(), map()) :: {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def transfer(client, attrs) do
    Client.post(client, "#{@base_path}/_transfer", attrs) |> Response.to_struct(Domain)
  end

  @doc "Initiates a domain trade (change of registrant)."
  @spec trade(Client.t(), map()) :: {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def trade(client, attrs) do
    Client.post(client, "#{@base_path}/_trade", attrs) |> Response.to_struct(Domain)
  end

  @doc "Buys a domain (aftermarket)."
  @spec buy(Client.t(), map()) :: {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def buy(client, attrs) do
    Client.post(client, "#{@base_path}/_buy", attrs) |> Response.to_struct(Domain)
  end

  @doc "Initiates a domain owner change."
  @spec owner_change(Client.t(), map()) :: {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def owner_change(client, attrs) do
    Client.post(client, "#{@base_path}/_ownerChange", attrs) |> Response.to_struct(Domain)
  end

  @doc "Renews a domain."
  @spec renew(Client.t(), String.t(), map()) ::
          {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def renew(client, name, attrs \\ %{}) do
    Client.put(client, "#{@base_path}/#{name}/_renew", attrs) |> Response.to_struct(Domain)
  end

  @doc "Restores a domain."
  @spec restore(Client.t(), String.t(), map()) ::
          {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def restore(client, name, attrs \\ %{}) do
    Client.put(client, "#{@base_path}/#{name}/_restore", attrs) |> Response.to_struct(Domain)
  end

  @doc "Lists domains pending restore."
  @spec restore_list(Client.t(), map()) ::
          {:ok, [Domain.t()]} | {:error, AutoDNS.Error.t()}
  def restore_list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/restore/_search", query) |> Response.to_list(Domain)
  end

  @doc "Lists domains pending auto-deletion."
  @spec auto_delete_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def auto_delete_list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/autodelete/_search", query) |> Response.data()
  end

  @doc "Creates AuthInfo1 for a domain."
  @spec create_authinfo1(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_authinfo1(client, name) do
    Client.post(client, "#{@base_path}/#{name}/_authinfo1") |> Response.object()
  end

  @doc "Deletes AuthInfo1 for a domain."
  @spec delete_authinfo1(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_authinfo1(client, name) do
    Client.delete(client, "#{@base_path}/#{name}/_authinfo1") |> Response.body()
  end

  @doc "Creates AuthInfo2 for a domain."
  @spec create_authinfo2(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_authinfo2(client, name) do
    Client.post(client, "#{@base_path}/#{name}/_authinfo2") |> Response.object()
  end

  @doc "Updates DNSSEC for a domain."
  @spec update_dnssec(Client.t(), String.t(), map()) ::
          {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def update_dnssec(client, name, attrs) do
    Client.put(client, "#{@base_path}/#{name}/_dnssec", attrs) |> Response.to_struct(Domain)
  end

  @doc "Triggers automatic DNSSEC key rollover for a domain."
  @spec auto_dnssec_key_rollover(Client.t(), String.t(), map()) ::
          {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def auto_dnssec_key_rollover(client, name, attrs \\ %{}) do
    Client.put(client, "#{@base_path}/#{name}/_autoDnssecKeyRollover", attrs)
    |> Response.to_struct(Domain)
  end

  @doc "Updates a domain's comment."
  @spec update_comment(Client.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, name, attrs) do
    Client.put(client, "#{@base_path}/#{name}/_comment", attrs) |> Response.body()
  end

  @doc "Updates domain status."
  @spec update_status(Client.t(), String.t(), map()) ::
          {:ok, Domain.t()} | {:error, AutoDNS.Error.t()}
  def update_status(client, name, attrs) do
    Client.put(client, "#{@base_path}/#{name}/_statusUpdate", attrs) |> Response.to_struct(Domain)
  end

  @doc "Adds a domain to DomainSafe."
  @spec add_domain_safe(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def add_domain_safe(client, name) do
    Client.put(client, "#{@base_path}/#{name}/_domainSafe") |> Response.body()
  end

  @doc "Removes a domain from DomainSafe."
  @spec delete_domain_safe(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_domain_safe(client, name) do
    Client.delete(client, "#{@base_path}/#{name}/_domainSafe") |> Response.body()
  end

  @doc "Updates domain services."
  @spec update_services(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_services(client, attrs) do
    Client.put(client, "#{@base_path}/_services", attrs) |> Response.body()
  end

  @doc "Sends authinfo to the owner contact."
  @spec send_authinfo_to_ownerc(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def send_authinfo_to_ownerc(client, name) do
    Client.put(client, "#{@base_path}/#{name}/_sendAuthinfoToOwnerc") |> Response.body()
  end
end
