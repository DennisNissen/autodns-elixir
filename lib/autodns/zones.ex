defmodule AutoDNS.Zones do
  @moduledoc """
  Operations on AutoDNS DNS Zones.

  ## Creating a Zone

      {:ok, zone} = AutoDNS.Zones.create(client, %{
        "origin" => "example.com",
        "virtualNameServer" => "a.ns14.net",
        "resourceRecords" => [
          %{"name" => "www", "type" => "A", "value" => "1.2.3.4", "ttl" => 3600}
        ]
      })

  ## Updating a Zone

      {:ok, zone} = AutoDNS.Zones.update(client, "example.com", "a.ns14.net", %{
        "resourceRecords" => [
          %{"name" => "mail", "type" => "A", "value" => "5.6.7.8", "ttl" => 3600}
        ]
      })

  """

  alias AutoDNS.Client

  @base_path "/zone"

  @doc "Creates a new DNS zone."
  @spec create(Client.t(), map()) :: {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for DNS zones."
  @spec list(Client.t(), map()) :: {:ok, [AutoDNS.Zone.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Zone.from_list(response.data || [])}
    end
  end

  @doc "Gets a zone by name."
  @spec get(Client.t(), String.t()) :: {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{name}") do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Gets a zone by name and virtual name server."
  @spec get(Client.t(), String.t(), String.t()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name, virtual_name_server) do
    with {:ok, response} <-
           Client.get(client, "#{@base_path}/#{name}/#{virtual_name_server}") do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a zone."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a zone with virtual name server."
  @spec update(Client.t(), String.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a zone."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{name}") do
      {:ok, response.body}
    end
  end

  @doc "Deletes a zone with virtual name server."
  @spec delete(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name, virtual_name_server) do
    with {:ok, response} <-
           Client.delete(client, "#{@base_path}/#{name}/#{virtual_name_server}") do
      {:ok, response.body}
    end
  end

  @doc "Patches a zone (partial update)."
  @spec patch(Client.t(), String.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def patch(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.patch(client, "#{@base_path}/#{name}/#{virtual_name_server}", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Streams zone updates."
  @spec stream(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def stream(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.post(client, "#{@base_path}/#{name}/#{virtual_name_server}/_stream", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Imports a zone."
  @spec import_zone(Client.t(), String.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def import_zone(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.post(client, "#{@base_path}/#{name}/#{virtual_name_server}/_import", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Performs an AXFR zone transfer."
  @spec axfr(Client.t(), String.t(), String.t()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def axfr(client, name, virtual_name_server) do
    with {:ok, response} <-
           Client.get(client, "#{@base_path}/#{name}/#{virtual_name_server}/_axfr") do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Copies a zone."
  @spec copy(Client.t(), String.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def copy(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_copy", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Migrates a zone."
  @spec migrate(Client.t(), String.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def migrate(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_migrate", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Restores a zone from history."
  @spec restore(Client.t(), String.t(), String.t(), map()) ::
          {:ok, AutoDNS.Zone.t()} | {:error, AutoDNS.Error.t()}
  def restore(client, name, virtual_name_server, attrs \\ %{}) do
    with {:ok, response} <-
           Client.post(client, "#{@base_path}/#{name}/#{virtual_name_server}/_restore", attrs) do
      {:ok, AutoDNS.Zone.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a zone's comment."
  @spec update_comment(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, name, virtual_name_server, attrs) do
    with {:ok, response} <-
           Client.put(
             client,
             "#{@base_path}/#{name}/#{virtual_name_server}/_comment",
             attrs
           ) do
      {:ok, response.body}
    end
  end

  @doc "Adds a zone to DomainSafe."
  @spec add_domain_safe(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def add_domain_safe(client, name, virtual_name_server) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_domainSafe") do
      {:ok, response.body}
    end
  end

  @doc "Removes a zone from DomainSafe."
  @spec delete_domain_safe(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_domain_safe(client, name, virtual_name_server) do
    with {:ok, response} <-
           Client.delete(
             client,
             "#{@base_path}/#{name}/#{virtual_name_server}/_domainSafe"
           ) do
      {:ok, response.body}
    end
  end

  @doc "Lists zone history."
  @spec history_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def history_list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/history/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Gets a zone history entry."
  @spec history_get(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def history_get(client, log_id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/history/#{log_id}") do
      {:ok, response.object || response.body}
    end
  end
end
