defmodule AutoDNS.TransferOuts do
  @moduledoc """
  Operations on AutoDNS outgoing domain transfers.

  ## Example

      {:ok, transfers} = AutoDNS.TransferOuts.list(client)
      {:ok, transfer} = AutoDNS.TransferOuts.get(client, "example.com")

  """

  alias AutoDNS.{Client, Response, TransferOut}

  @base_path "/transferout"

  @doc "Searches for outgoing transfers."
  @spec list(Client.t(), map()) :: {:ok, [TransferOut.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(TransferOut)
  end

  @doc "Gets an outgoing transfer by domain name."
  @spec get(Client.t(), String.t()) :: {:ok, TransferOut.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    Client.get(client, "#{@base_path}/#{name}") |> Response.to_struct(TransferOut)
  end

  @doc "Answers an outgoing transfer (ACK/NACK)."
  @spec answer(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def answer(client, domain, type, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{domain}/#{type}", attrs) |> Response.body()
  end
end
