defmodule AutoDNS.Hello do
  @moduledoc """
  AutoDNS health check endpoint.

  ## Example

      {:ok, response} = AutoDNS.Hello.hello(client)

  """

  alias AutoDNS.{Client, Response}

  @doc "Performs a health check against the AutoDNS API."
  @spec hello(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def hello(client) do
    Client.get(client, "/hello") |> Response.body()
  end
end
