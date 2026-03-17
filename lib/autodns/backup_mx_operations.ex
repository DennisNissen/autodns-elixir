defmodule AutoDNS.BackupMxOps do
  @moduledoc """
  Operations on AutoDNS BackupMx configurations.

  ## Example

      {:ok, backup_mx} = AutoDNS.BackupMxOps.create(client, %{
        "domain" => "example.com",
        "target" => "backup.example.com"
      })

  """

  alias AutoDNS.Client

  @base_path "/backupMx"

  @doc "Creates a new BackupMx configuration."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.BackupMx.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.BackupMx.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for BackupMx configurations."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.BackupMx.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.BackupMx.from_list(response.data || [])}
    end
  end

  @doc "Gets a BackupMx configuration by domain."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.BackupMx.t()} | {:error, AutoDNS.Error.t()}
  def get(client, domain) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{domain}") do
      {:ok, AutoDNS.BackupMx.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a BackupMx configuration."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, domain) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{domain}") do
      {:ok, response.body}
    end
  end
end
