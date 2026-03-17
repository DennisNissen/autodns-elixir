defmodule AutoDNS.ZoneQueries do
  @moduledoc """
  Operations on AutoDNS zone queries.

  ## Example

      {:ok, results} = AutoDNS.ZoneQueries.list(client, %{
        "filters" => [%{"key" => "origin", "value" => "example.com"}]
      })

  """

  alias AutoDNS.Client

  @doc "Searches for zone queries."
  @spec list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "/zone/zoneQuery/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Searches for zone-specific queries."
  @spec base_list(Client.t(), String.t(), String.t(), map()) ::
          {:ok, list()} | {:error, AutoDNS.Error.t()}
  def base_list(client, name, virtual_name_server, query \\ %{}) do
    with {:ok, response} <-
           Client.post(
             client,
             "/zone/#{name}/#{virtual_name_server}/zoneQuery/_search",
             query
           ) do
      {:ok, response.data || []}
    end
  end
end
