defmodule AutoDNS.Hello do
  @moduledoc """
  AutoDNS health check endpoint.

  ## Example

      {:ok, response} = AutoDNS.Hello.hello(client)

  """

  alias AutoDNS.Client

  @doc "Performs a health check against the AutoDNS API."
  @spec hello(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def hello(client) do
    with {:ok, response} <- Client.get(client, "/hello") do
      {:ok, response.body}
    end
  end
end
