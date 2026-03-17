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

  alias AutoDNS.Client

  @base_path "/sslcontact"

  @doc "Creates a new SSL contact."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.SslContact.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.SslContact.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for SSL contacts."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.SslContact.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.SslContact.from_list(response.data || [])}
    end
  end

  @doc "Gets an SSL contact by ID."
  @spec get(Client.t(), integer()) ::
          {:ok, AutoDNS.SslContact.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{id}") do
      {:ok, AutoDNS.SslContact.from_map(response.object || response.body)}
    end
  end

  @doc "Updates an SSL contact."
  @spec update(Client.t(), integer(), map()) ::
          {:ok, AutoDNS.SslContact.t()} | {:error, AutoDNS.Error.t()}
  def update(client, id, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}", attrs) do
      {:ok, AutoDNS.SslContact.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes an SSL contact."
  @spec delete(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, id) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{id}") do
      {:ok, response.body}
    end
  end
end
