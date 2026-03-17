defmodule AutoDNS.TransferOuts do
  @moduledoc """
  Operations on AutoDNS outgoing domain transfers.

  ## Example

      {:ok, transfers} = AutoDNS.TransferOuts.list(client)
      {:ok, transfer} = AutoDNS.TransferOuts.get(client, "example.com")

  """

  alias AutoDNS.Client

  @base_path "/transferout"

  @doc "Searches for outgoing transfers."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.TransferOut.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.TransferOut.from_list(response.data || [])}
    end
  end

  @doc "Gets an outgoing transfer by domain name."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.TransferOut.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{name}") do
      {:ok, AutoDNS.TransferOut.from_map(response.object || response.body)}
    end
  end

  @doc "Answers an outgoing transfer (ACK/NACK)."
  @spec answer(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def answer(client, domain, type, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{domain}/#{type}", attrs) do
      {:ok, response.body}
    end
  end
end
