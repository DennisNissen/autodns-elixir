defmodule AutoDNS.DomainCancelations do
  @moduledoc """
  Operations on AutoDNS domain cancelations.

  ## Example

      {:ok, cancelation} = AutoDNS.DomainCancelations.create(client, "example.com", %{
        "type" => "DELETE",
        "execution" => "2024-12-31"
      })

  """

  alias AutoDNS.{Client, DomainCancelation, Response}

  @doc "Creates a domain cancelation."
  @spec create(Client.t(), String.t(), map()) ::
          {:ok, DomainCancelation.t()} | {:error, AutoDNS.Error.t()}
  def create(client, name, attrs) do
    Client.post(client, "/domain/#{name}/cancelation", attrs)
    |> Response.to_struct(DomainCancelation)
  end

  @doc "Searches for domain cancelations."
  @spec list(Client.t(), map()) ::
          {:ok, [DomainCancelation.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "/domain/cancelation/_search", query)
    |> Response.to_list(DomainCancelation)
  end

  @doc "Gets a domain cancelation."
  @spec get(Client.t(), String.t()) ::
          {:ok, DomainCancelation.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    Client.get(client, "/domain/#{name}/cancelation") |> Response.to_struct(DomainCancelation)
  end

  @doc "Updates a domain cancelation."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, DomainCancelation.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, attrs) do
    Client.put(client, "/domain/#{name}/cancelation", attrs)
    |> Response.to_struct(DomainCancelation)
  end

  @doc "Deletes a domain cancelation."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name) do
    Client.delete(client, "/domain/#{name}/cancelation") |> Response.body()
  end
end
