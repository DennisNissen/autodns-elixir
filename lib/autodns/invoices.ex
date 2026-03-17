defmodule AutoDNS.Invoices do
  @moduledoc """
  Operations on AutoDNS invoices.

  ## Example

      {:ok, invoices} = AutoDNS.Invoices.list(client)
      {:ok, invoice} = AutoDNS.Invoices.get(client, 12345)

  """

  alias AutoDNS.Client

  @base_path "/invoice"

  @doc "Searches for invoices."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.Invoice.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Invoice.from_list(response.data || [])}
    end
  end

  @doc "Gets an invoice by ID."
  @spec get(Client.t(), integer()) ::
          {:ok, AutoDNS.Invoice.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{id}") do
      {:ok, AutoDNS.Invoice.from_map(response.object || response.body)}
    end
  end
end
