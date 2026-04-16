defmodule AutoDNS.DomainSafe do
  @moduledoc """
  Operations on AutoDNS DomainSafe contacts, objects, and users.

  DomainSafe provides an additional layer of security for domain management.

  ## Example

      {:ok, contacts} = AutoDNS.DomainSafe.list_contacts(client)

  """

  alias AutoDNS.{Client, Response}

  @doc "Creates a DomainSafe contact."
  @spec create_contact(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_contact(client, attrs) do
    Client.post(client, "/domainSafeContact", attrs) |> Response.object()
  end

  @doc "Searches for DomainSafe contacts."
  @spec list_contacts(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_contacts(client, query \\ %{}) do
    Client.post(client, "/domainSafeContact/_search", query) |> Response.data()
  end

  @doc "Gets a DomainSafe contact by ID."
  @spec get_contact(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_contact(client, id) do
    Client.get(client, "/domainSafeContact/#{id}") |> Response.object()
  end

  @doc "Updates a DomainSafe contact."
  @spec update_contact(Client.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_contact(client, id, attrs) do
    Client.put(client, "/domainSafeContact/#{id}", attrs) |> Response.object()
  end

  @doc "Creates a DomainSafe user."
  @spec create_user(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_user(client, attrs) do
    Client.post(client, "/domainSafeContact/user", attrs) |> Response.object()
  end

  @doc "Updates a DomainSafe user."
  @spec update_user(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_user(client, attrs) do
    Client.put(client, "/domainSafeContact/user", attrs) |> Response.object()
  end

  @doc "Deletes a DomainSafe user."
  @spec delete_user(Client.t(), String.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_user(client, user, context) do
    Client.delete(client, "/domainSafeContact/user/#{user}/#{context}") |> Response.body()
  end

  @doc "Creates a DomainSafe object."
  @spec create_object(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_object(client, attrs) do
    Client.post(client, "/domainSafeObject", attrs) |> Response.object()
  end

  @doc "Searches for DomainSafe objects."
  @spec list_objects(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_objects(client, query \\ %{}) do
    Client.post(client, "/domainSafeObject/_search", query) |> Response.data()
  end

  @doc "Deletes a DomainSafe object."
  @spec delete_object(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_object(client, safe_object, type) do
    Client.delete(client, "/domainSafeObject/#{safe_object}/#{type}") |> Response.body()
  end
end
