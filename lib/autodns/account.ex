defmodule AutoDNS.Account do
  @moduledoc """
  Operations on AutoDNS customer account.

  ## Example

      {:ok, account} = AutoDNS.Account.info(client)

  """

  alias AutoDNS.{AccountData, Client, Response}

  @doc "Gets the account information for the current customer."
  @spec info(Client.t()) :: {:ok, AccountData.t()} | {:error, AutoDNS.Error.t()}
  def info(client) do
    Client.get(client, "/account") |> Response.to_struct(AccountData)
  end

  @doc "Updates account notification parameters."
  @spec update(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update(client, attrs) do
    Client.post(client, "/account", attrs) |> Response.object()
  end
end
