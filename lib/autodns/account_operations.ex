defmodule AutoDNS.Account do
  @moduledoc """
  Operations on AutoDNS customer account.

  ## Example

      {:ok, account} = AutoDNS.Account.info(client)

  """

  alias AutoDNS.Client

  @doc "Gets the account information for the current customer."
  @spec info(Client.t()) :: {:ok, AutoDNS.AccountData.t()} | {:error, AutoDNS.Error.t()}
  def info(client) do
    with {:ok, response} <- Client.get(client, "/account") do
      {:ok, AutoDNS.AccountData.from_map(response.object || response.body)}
    end
  end

  @doc "Updates account notification parameters."
  @spec update(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update(client, attrs) do
    with {:ok, response} <- Client.post(client, "/account", attrs) do
      {:ok, response.object || response.body}
    end
  end
end
