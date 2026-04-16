defmodule AutoDNS.Redirects do
  @moduledoc """
  Operations on AutoDNS redirects.

  ## Example

      {:ok, redirect} = AutoDNS.Redirects.create(client, %{
        "source" => "old.example.com",
        "target" => "https://new.example.com",
        "type" => "HEADER301"
      })

  """

  alias AutoDNS.{Client, Redirect, Response}

  @base_path "/redirect"

  @doc "Creates a new redirect."
  @spec create(Client.t(), map()) :: {:ok, Redirect.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(Redirect)
  end

  @doc "Searches for redirects."
  @spec list(Client.t(), map()) :: {:ok, [Redirect.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Redirect)
  end

  @doc "Gets a redirect by source."
  @spec get(Client.t(), String.t()) :: {:ok, Redirect.t()} | {:error, AutoDNS.Error.t()}
  def get(client, source) do
    Client.get(client, "#{@base_path}/#{source}") |> Response.to_struct(Redirect)
  end

  @doc "Updates a redirect."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, Redirect.t()} | {:error, AutoDNS.Error.t()}
  def update(client, source, attrs) do
    Client.put(client, "#{@base_path}/#{source}", attrs) |> Response.to_struct(Redirect)
  end

  @doc "Deletes a redirect."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, source) do
    Client.delete(client, "#{@base_path}/#{source}") |> Response.body()
  end
end
