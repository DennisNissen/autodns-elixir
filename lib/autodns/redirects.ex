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

  alias AutoDNS.Client

  @base_path "/redirect"

  @doc "Creates a new redirect."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.Redirect.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.Redirect.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for redirects."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.Redirect.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Redirect.from_list(response.data || [])}
    end
  end

  @doc "Gets a redirect by source."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.Redirect.t()} | {:error, AutoDNS.Error.t()}
  def get(client, source) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{source}") do
      {:ok, AutoDNS.Redirect.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a redirect."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Redirect.t()} | {:error, AutoDNS.Error.t()}
  def update(client, source, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{source}", attrs) do
      {:ok, AutoDNS.Redirect.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a redirect."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, source) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{source}") do
      {:ok, response.body}
    end
  end
end
