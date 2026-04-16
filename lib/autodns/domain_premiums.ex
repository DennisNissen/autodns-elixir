defmodule AutoDNS.DomainPremiums do
  @moduledoc """
  Operations on AutoDNS premium domains.

  ## Example

      {:ok, premium} = AutoDNS.DomainPremiums.get(client, "example.com")

  """

  alias AutoDNS.{Client, Response}

  @doc "Gets premium domain information."
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    Client.get(client, "/domainpremium/#{name}") |> Response.object()
  end
end
