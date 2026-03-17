defmodule AutoDNS.DomainSafe do
  @moduledoc """
  Operations on AutoDNS DomainSafe contacts, objects, and users.

  DomainSafe provides an additional layer of security for domain management.

  ## Example

      {:ok, contacts} = AutoDNS.DomainSafe.list_contacts(client)

  """

  alias AutoDNS.Client

  # -- Contacts --

  @doc "Creates a DomainSafe contact."
  @spec create_contact(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_contact(client, attrs) do
    with {:ok, response} <- Client.post(client, "/domainSafeContact", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Searches for DomainSafe contacts."
  @spec list_contacts(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_contacts(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "/domainSafeContact/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Gets a DomainSafe contact by ID."
  @spec get_contact(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_contact(client, id) do
    with {:ok, response} <- Client.get(client, "/domainSafeContact/#{id}") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Updates a DomainSafe contact."
  @spec update_contact(Client.t(), integer(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_contact(client, id, attrs) do
    with {:ok, response} <- Client.put(client, "/domainSafeContact/#{id}", attrs) do
      {:ok, response.object || response.body}
    end
  end

  # -- Users --

  @doc "Creates a DomainSafe user."
  @spec create_user(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_user(client, attrs) do
    with {:ok, response} <- Client.post(client, "/domainSafeContact/user", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Updates a DomainSafe user."
  @spec update_user(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_user(client, attrs) do
    with {:ok, response} <- Client.put(client, "/domainSafeContact/user", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Deletes a DomainSafe user."
  @spec delete_user(Client.t(), String.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_user(client, user, context) do
    with {:ok, response} <- Client.delete(client, "/domainSafeContact/user/#{user}/#{context}") do
      {:ok, response.body}
    end
  end

  # -- Objects --

  @doc "Creates a DomainSafe object."
  @spec create_object(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_object(client, attrs) do
    with {:ok, response} <- Client.post(client, "/domainSafeObject", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Searches for DomainSafe objects."
  @spec list_objects(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_objects(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "/domainSafeObject/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Deletes a DomainSafe object."
  @spec delete_object(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_object(client, safe_object, type) do
    with {:ok, response} <- Client.delete(client, "/domainSafeObject/#{safe_object}/#{type}") do
      {:ok, response.body}
    end
  end
end
