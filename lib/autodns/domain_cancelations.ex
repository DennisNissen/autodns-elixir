defmodule AutoDNS.DomainCancelations do
  @moduledoc """
  Operations on AutoDNS domain cancelations.

  ## Example

      {:ok, cancelation} = AutoDNS.DomainCancelations.create(client, "example.com", %{
        "type" => "DELETE",
        "execution" => "2024-12-31"
      })

  """

  alias AutoDNS.Client

  @doc "Creates a domain cancelation."
  @spec create(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.DomainCancelation.t()} | {:error, AutoDNS.Error.t()}
  def create(client, name, attrs) do
    with {:ok, response} <- Client.post(client, "/domain/#{name}/cancelation", attrs) do
      {:ok, AutoDNS.DomainCancelation.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for domain cancelations."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.DomainCancelation.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "/domain/cancelation/_search", query) do
      {:ok, AutoDNS.DomainCancelation.from_list(response.data || [])}
    end
  end

  @doc "Gets a domain cancelation."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.DomainCancelation.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    with {:ok, response} <- Client.get(client, "/domain/#{name}/cancelation") do
      {:ok, AutoDNS.DomainCancelation.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a domain cancelation."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.DomainCancelation.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, attrs) do
    with {:ok, response} <- Client.put(client, "/domain/#{name}/cancelation", attrs) do
      {:ok, AutoDNS.DomainCancelation.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a domain cancelation."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name) do
    with {:ok, response} <- Client.delete(client, "/domain/#{name}/cancelation") do
      {:ok, response.body}
    end
  end
end
