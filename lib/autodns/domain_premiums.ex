defmodule AutoDNS.DomainPremiums do
  @moduledoc """
  Operations on AutoDNS premium domains.

  ## Example

      {:ok, premium} = AutoDNS.DomainPremiums.get(client, "example.com")

  """

  alias AutoDNS.Client

  @doc "Gets premium domain information."
  @spec get(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    with {:ok, response} <- Client.get(client, "/domainpremium/#{name}") do
      {:ok, response.object || response.body}
    end
  end
end
