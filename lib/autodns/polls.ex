defmodule AutoDNS.Polls do
  @moduledoc """
  Operations on AutoDNS poll messages.

  Poll messages notify you about asynchronous events such as completed
  domain transfers, certificate issuances, etc.

  ## Example

      {:ok, poll} = AutoDNS.Polls.get(client)
      :ok = AutoDNS.Polls.confirm(client, 12345)

  """

  alias AutoDNS.{Client, Poll, Response}

  @doc "Gets the oldest unconfirmed poll message."
  @spec get(Client.t()) :: {:ok, Poll.t()} | {:error, AutoDNS.Error.t()}
  def get(client) do
    Client.get(client, "/poll") |> Response.to_struct(Poll)
  end

  @doc "Confirms (acknowledges) a poll message."
  @spec confirm(Client.t(), integer()) :: :ok | {:error, AutoDNS.Error.t()}
  def confirm(client, id) do
    case Client.put(client, "/poll/#{id}") do
      {:ok, _} -> :ok
      {:error, _} = error -> error
    end
  end
end
