defmodule AutoDNS.TmchClaims do
  @moduledoc """
  Operations on AutoDNS TMCH claims notices.

  ## Example

      {:ok, claims} = AutoDNS.TmchClaims.list(client)

  """

  alias AutoDNS.Client

  @base_path "/tmchMark/claim"

  @doc "Searches for TMCH claims."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.TmchClaim.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.TmchClaim.from_list(response.data || [])}
    end
  end

  @doc "Gets a TMCH claim by reference."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.TmchClaim.t()} | {:error, AutoDNS.Error.t()}
  def get(client, reference) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{reference}") do
      {:ok, AutoDNS.TmchClaim.from_map(response.object || response.body)}
    end
  end

  @doc "Confirms a TMCH claim."
  @spec confirm(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm(client, reference, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{reference}/_confirm", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Rejects a TMCH claim."
  @spec reject(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def reject(client, reference) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{reference}/_reject") do
      {:ok, response.body}
    end
  end
end
