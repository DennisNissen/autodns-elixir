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

  alias AutoDNS.{Client, Response, Zone}

  @base_path "/zone"

  @doc "Creates a new DNS zone."
  @spec create(Client.t(), map()) :: {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(Zone)
  end

  @doc "Searches for DNS zones."
  @spec list(Client.t(), map()) :: {:ok, [Zone.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Zone)
  end

  @doc "Gets a zone by name."
  @spec get(Client.t(), String.t()) :: {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name) do
    Client.get(client, "#{@base_path}/#{name}") |> Response.to_struct(Zone)
  end

  @doc "Gets a zone by name and virtual name server."
  @spec get(Client.t(), String.t(), String.t()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name, virtual_name_server) do
    Client.get(client, "#{@base_path}/#{name}/#{virtual_name_server}")
    |> Response.to_struct(Zone)
  end

  @doc "Updates a zone."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, attrs) do
    Client.put(client, "#{@base_path}/#{name}", attrs) |> Response.to_struct(Zone)
  end

  @doc "Updates a zone with virtual name server."
  @spec update(Client.t(), String.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, virtual_name_server, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}", attrs)
    |> Response.to_struct(Zone)
  end

  @doc "Deletes a zone."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name) do
    Client.delete(client, "#{@base_path}/#{name}") |> Response.body()
  end

  @doc "Deletes a zone with virtual name server."
  @spec delete(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name, virtual_name_server) do
    Client.delete(client, "#{@base_path}/#{name}/#{virtual_name_server}") |> Response.body()
  end

  @doc "Patches a zone (partial update)."
  @spec patch(Client.t(), String.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def patch(client, name, virtual_name_server, attrs) do
    Client.patch(client, "#{@base_path}/#{name}/#{virtual_name_server}", attrs)
    |> Response.to_struct(Zone)
  end

  @doc "Streams zone updates."
  @spec stream(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def stream(client, name, virtual_name_server, attrs) do
    Client.post(client, "#{@base_path}/#{name}/#{virtual_name_server}/_stream", attrs)
    |> Response.body()
  end

  @doc "Imports a zone."
  @spec import_zone(Client.t(), String.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def import_zone(client, name, virtual_name_server, attrs) do
    Client.post(client, "#{@base_path}/#{name}/#{virtual_name_server}/_import", attrs)
    |> Response.to_struct(Zone)
  end

  @doc "Performs an AXFR zone transfer."
  @spec axfr(Client.t(), String.t(), String.t()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def axfr(client, name, virtual_name_server) do
    Client.get(client, "#{@base_path}/#{name}/#{virtual_name_server}/_axfr")
    |> Response.to_struct(Zone)
  end

  @doc "Copies a zone."
  @spec copy(Client.t(), String.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def copy(client, name, virtual_name_server, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_copy", attrs)
    |> Response.to_struct(Zone)
  end

  @doc "Migrates a zone."
  @spec migrate(Client.t(), String.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def migrate(client, name, virtual_name_server, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_migrate", attrs)
    |> Response.to_struct(Zone)
  end

  @doc "Restores a zone from history."
  @spec restore(Client.t(), String.t(), String.t(), map()) ::
          {:ok, Zone.t()} | {:error, AutoDNS.Error.t()}
  def restore(client, name, virtual_name_server, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{name}/#{virtual_name_server}/_restore", attrs)
    |> Response.to_struct(Zone)
  end

  @doc "Updates a zone's comment."
  @spec update_comment(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, name, virtual_name_server, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_comment", attrs)
    |> Response.body()
  end

  @doc "Adds a zone to DomainSafe."
  @spec add_domain_safe(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def add_domain_safe(client, name, virtual_name_server) do
    Client.put(client, "#{@base_path}/#{name}/#{virtual_name_server}/_domainSafe")
    |> Response.body()
  end

  @doc "Removes a zone from DomainSafe."
  @spec delete_domain_safe(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_domain_safe(client, name, virtual_name_server) do
    Client.delete(client, "#{@base_path}/#{name}/#{virtual_name_server}/_domainSafe")
    |> Response.body()
  end

  @doc "Lists zone history."
  @spec history_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def history_list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/history/_search", query) |> Response.data()
  end

  @doc "Gets a zone history entry."
  @spec history_get(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def history_get(client, log_id) do
    Client.get(client, "#{@base_path}/history/#{log_id}") |> Response.object()
  end
end
