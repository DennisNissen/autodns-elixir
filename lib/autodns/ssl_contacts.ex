defmodule AutoDNS.SslContacts do
  @moduledoc """
  Operations on AutoDNS SSL contacts.

  ## Example

      {:ok, contact} = AutoDNS.SslContacts.create(client, %{
        "fname" => "John",
        "lname" => "Doe",
        "email" => "john@example.com",
        "organization" => "Acme Inc."
      })

  """

  alias AutoDNS.{Client, Response, SslContact}

  @base_path "/sslcontact"

  @doc "Creates a new SSL contact."
  @spec create(Client.t(), map()) :: {:ok, SslContact.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(SslContact)
  end

  @doc "Searches for SSL contacts."
  @spec list(Client.t(), map()) :: {:ok, [SslContact.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(SslContact)
  end

  @doc "Gets an SSL contact by ID."
  @spec get(Client.t(), integer()) :: {:ok, SslContact.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    Client.get(client, "#{@base_path}/#{id}") |> Response.to_struct(SslContact)
  end

  @doc "Updates an SSL contact."
  @spec update(Client.t(), integer(), map()) ::
          {:ok, SslContact.t()} | {:error, AutoDNS.Error.t()}
  def update(client, id, attrs) do
    Client.put(client, "#{@base_path}/#{id}", attrs) |> Response.to_struct(SslContact)
  end

  @doc "Deletes an SSL contact."
  @spec delete(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, id) do
    Client.delete(client, "#{@base_path}/#{id}") |> Response.body()
  end
end
