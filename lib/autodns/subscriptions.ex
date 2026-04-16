defmodule AutoDNS.Subscriptions do
  @moduledoc """
  Operations on AutoDNS subscriptions.

  ## Example

      {:ok, subscriptions} = AutoDNS.Subscriptions.list(client)

  """

  alias AutoDNS.{Client, Response, Subscription}

  @base_path "/subscription"

  @doc "Creates a new subscription."
  @spec create(Client.t(), map()) :: {:ok, Subscription.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(Subscription)
  end

  @doc "Searches for subscriptions."
  @spec list(Client.t(), map()) :: {:ok, [Subscription.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Subscription)
  end

  @doc "Updates a subscription."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, Subscription.t()} | {:error, AutoDNS.Error.t()}
  def update(client, contract_id, attrs) do
    Client.put(client, "#{@base_path}/#{contract_id}", attrs) |> Response.to_struct(Subscription)
  end

  @doc "Deletes a subscription."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, contract_id) do
    Client.delete(client, "#{@base_path}/#{contract_id}") |> Response.body()
  end

  @doc "Upgrades a subscription."
  @spec upgrade(Client.t(), String.t(), map()) ::
          {:ok, Subscription.t()} | {:error, AutoDNS.Error.t()}
  def upgrade(client, contract_id, attrs) do
    Client.put(client, "#{@base_path}/#{contract_id}/_upgrade", attrs)
    |> Response.to_struct(Subscription)
  end

  @doc "Creates a subscription cancelation."
  @spec create_cancelation(Client.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_cancelation(client, contract_id, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{contract_id}/cancelation", attrs) |> Response.object()
  end

  @doc "Deletes a subscription cancelation."
  @spec delete_cancelation(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_cancelation(client, contract_id) do
    Client.delete(client, "#{@base_path}/#{contract_id}/cancelation") |> Response.body()
  end
end
