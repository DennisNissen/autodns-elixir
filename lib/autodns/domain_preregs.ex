defmodule AutoDNS.DomainPreregs do
  @moduledoc """
  Operations on AutoDNS domain pre-registrations.

  ## Example

      {:ok, prereg} = AutoDNS.DomainPreregs.create(client, %{
        "name" => "example.new",
        "ownerc" => %{"fname" => "John", "lname" => "Doe"}
      })

  """

  alias AutoDNS.Client

  @base_path "/domainPrereg"

  @doc "Creates a new domain pre-registration."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.DomainPrereg.from_map(response.object || response.body)}
    end
  end

  @doc "Creates and confirms a pre-registration in one step."
  @spec create_and_confirm(Client.t(), map()) ::
          {:ok, AutoDNS.DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def create_and_confirm(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_confirm", attrs) do
      {:ok, AutoDNS.DomainPrereg.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for domain pre-registrations."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.DomainPrereg.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.DomainPrereg.from_list(response.data || [])}
    end
  end

  @doc "Gets a domain pre-registration by reference."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def get(client, reference) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{reference}") do
      {:ok, AutoDNS.DomainPrereg.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a domain pre-registration."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def update(client, reference, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{reference}", attrs) do
      {:ok, AutoDNS.DomainPrereg.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a domain pre-registration."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, reference) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{reference}") do
      {:ok, response.body}
    end
  end

  @doc "Confirms a domain pre-registration."
  @spec confirm(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def confirm(client, reference, attrs \\ %{}) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{reference}/_confirm", attrs) do
      {:ok, AutoDNS.DomainPrereg.from_map(response.object || response.body)}
    end
  end
end
