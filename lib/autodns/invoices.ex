defmodule AutoDNS.Invoices do
  @moduledoc """
  Operations on AutoDNS invoices.

  ## Example

      {:ok, invoices} = AutoDNS.Invoices.list(client)
      {:ok, invoice} = AutoDNS.Invoices.get(client, 12345)

  """

  alias AutoDNS.{Client, Invoice, Response}

  @base_path "/invoice"

  @doc "Searches for invoices."
  @spec list(Client.t(), map()) :: {:ok, [Invoice.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Invoice)
  end

  @doc "Gets an invoice by ID."
  @spec get(Client.t(), integer()) :: {:ok, Invoice.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    Client.get(client, "#{@base_path}/#{id}") |> Response.to_struct(Invoice)
  end
end
