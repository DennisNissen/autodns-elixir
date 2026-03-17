defmodule AutoDNS.Subscriptions do
  @moduledoc """
  Operations on AutoDNS subscriptions.

  ## Example

      {:ok, subscriptions} = AutoDNS.Subscriptions.list(client)

  """

  alias AutoDNS.Client

  @base_path "/subscription"

  @doc "Creates a new subscription."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.Subscription.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.Subscription.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for subscriptions."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.Subscription.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Subscription.from_list(response.data || [])}
    end
  end

  @doc "Updates a subscription."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Subscription.t()} | {:error, AutoDNS.Error.t()}
  def update(client, contract_id, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{contract_id}", attrs) do
      {:ok, AutoDNS.Subscription.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a subscription."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, contract_id) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{contract_id}") do
      {:ok, response.body}
    end
  end

  @doc "Upgrades a subscription."
  @spec upgrade(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Subscription.t()} | {:error, AutoDNS.Error.t()}
  def upgrade(client, contract_id, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{contract_id}/_upgrade", attrs) do
      {:ok, AutoDNS.Subscription.from_map(response.object || response.body)}
    end
  end

  @doc "Creates a subscription cancelation."
  @spec create_cancelation(Client.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_cancelation(client, contract_id, attrs \\ %{}) do
    with {:ok, response} <-
           Client.post(client, "#{@base_path}/#{contract_id}/cancelation", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Deletes a subscription cancelation."
  @spec delete_cancelation(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_cancelation(client, contract_id) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{contract_id}/cancelation") do
      {:ok, response.body}
    end
  end
end
