defmodule AutoDNS.ContactDocuments do
  @moduledoc """
  Operations on AutoDNS contact documents.

  ## Example

      {:ok, doc} = AutoDNS.ContactDocuments.get(client, 123, "ID_CARD")

  """

  alias AutoDNS.{Client, Response}

  @doc "Creates a contact document."
  @spec create(Client.t(), integer(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create(client, contact_id, type, attrs) do
    Client.post(client, "/contact/#{contact_id}/document/#{type}", attrs) |> Response.object()
  end

  @doc "Gets a contact document."
  @spec get(Client.t(), integer(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get(client, contact_id, type) do
    Client.get(client, "/contact/#{contact_id}/document/#{type}") |> Response.object()
  end

  @doc "Patches a contact document."
  @spec patch(Client.t(), integer(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def patch(client, contact_id, type, attrs) do
    Client.patch(client, "/contact/#{contact_id}/document/#{type}", attrs) |> Response.object()
  end

  @doc "Deletes a contact document."
  @spec delete(Client.t(), integer(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, contact_id, type) do
    Client.delete(client, "/contact/#{contact_id}/document/#{type}") |> Response.body()
  end

  @doc "Copies a contact document."
  @spec copy(Client.t(), integer(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def copy(client, contact_id, type, attrs \\ %{}) do
    Client.post(client, "/contact/#{contact_id}/document/#{type}/_copy", attrs)
    |> Response.object()
  end
end
