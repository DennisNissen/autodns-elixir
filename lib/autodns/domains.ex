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

  alias AutoDNS.Client

  @base_path "/domain"

  @doc "Creates a new domain registration."
  @spec create(Client.t(), map()) :: {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for domains using a query object."
  @spec list(Client.t(), map()) :: {:ok, [AutoDNS.Domain.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Domain.from_list(response.data || [])}
    end
  end

  @doc "Gets a single domain by name."
  @spec get(Client.t(), String.t()) :: {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{name}") do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Updates an existing domain."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Transfers a domain."
  @spec transfer(Client.t(), map()) :: {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def transfer(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_transfer", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Initiates a domain trade (change of registrant)."
  @spec trade(Client.t(), map()) :: {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def trade(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_trade", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Buys a domain (aftermarket)."
  @spec buy(Client.t(), map()) :: {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def buy(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_buy", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Initiates a domain owner change."
  @spec owner_change(Client.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def owner_change(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_ownerChange", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Renews a domain."
  @spec renew(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def renew(client, name, attrs \\ %{}) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/_renew", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Restores a domain."
  @spec restore(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def restore(client, name, attrs \\ %{}) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/_restore", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Lists domains pending restore."
  @spec restore_list(Client.t(), map()) ::
          {:ok, [AutoDNS.Domain.t()]} | {:error, AutoDNS.Error.t()}
  def restore_list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/restore/_search", query) do
      {:ok, AutoDNS.Domain.from_list(response.data || [])}
    end
  end

  @doc "Lists domains pending auto-deletion."
  @spec auto_delete_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def auto_delete_list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/autodelete/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Creates AuthInfo1 for a domain."
  @spec create_authinfo1(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_authinfo1(client, name) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{name}/_authinfo1") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Deletes AuthInfo1 for a domain."
  @spec delete_authinfo1(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_authinfo1(client, name) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{name}/_authinfo1") do
      {:ok, response.body}
    end
  end

  @doc "Creates AuthInfo2 for a domain."
  @spec create_authinfo2(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_authinfo2(client, name) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{name}/_authinfo2") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Updates DNSSEC for a domain."
  @spec update_dnssec(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def update_dnssec(client, name, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/_dnssec", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Triggers automatic DNSSEC key rollover for a domain."
  @spec auto_dnssec_key_rollover(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def auto_dnssec_key_rollover(client, name, attrs \\ %{}) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/_autoDnssecKeyRollover", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a domain's comment."
  @spec update_comment(Client.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, name, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/_comment", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Updates domain status."
  @spec update_status(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Domain.t()} | {:error, AutoDNS.Error.t()}
  def update_status(client, name, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/_statusUpdate", attrs) do
      {:ok, AutoDNS.Domain.from_map(response.object || response.body)}
    end
  end

  @doc "Adds a domain to DomainSafe."
  @spec add_domain_safe(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def add_domain_safe(client, name) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/_domainSafe") do
      {:ok, response.body}
    end
  end

  @doc "Removes a domain from DomainSafe."
  @spec delete_domain_safe(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_domain_safe(client, name) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{name}/_domainSafe") do
      {:ok, response.body}
    end
  end

  @doc "Updates domain services."
  @spec update_services(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_services(client, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/_services", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Sends authinfo to the owner contact."
  @spec send_authinfo_to_ownerc(Client.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def send_authinfo_to_ownerc(client, name) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/_sendAuthinfoToOwnerc") do
      {:ok, response.body}
    end
  end
end
