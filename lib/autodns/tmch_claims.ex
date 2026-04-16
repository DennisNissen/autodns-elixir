defmodule AutoDNS.TmchClaims do
  @moduledoc """
  Operations on AutoDNS TMCH claims notices.

  ## Example

      {:ok, claims} = AutoDNS.TmchClaims.list(client)

  """

  alias AutoDNS.{Client, Response, TmchClaim}

  @base_path "/tmchMark/claim"

  @doc "Searches for TMCH claims."
  @spec list(Client.t(), map()) :: {:ok, [TmchClaim.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(TmchClaim)
  end

  @doc "Gets a TMCH claim by reference."
  @spec get(Client.t(), String.t()) :: {:ok, TmchClaim.t()} | {:error, AutoDNS.Error.t()}
  def get(client, reference) do
    Client.get(client, "#{@base_path}/#{reference}") |> Response.to_struct(TmchClaim)
  end

  @doc "Confirms a TMCH claim."
  @spec confirm(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm(client, reference, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{reference}/_confirm", attrs) |> Response.body()
  end

  @doc "Rejects a TMCH claim."
  @spec reject(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def reject(client, reference) do
    Client.put(client, "#{@base_path}/#{reference}/_reject") |> Response.body()
  end
end
