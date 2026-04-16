defmodule AutoDNS.BackupMxes do
  @moduledoc """
  Operations on AutoDNS BackupMx configurations.

  ## Example

      {:ok, backup_mx} = AutoDNS.BackupMxes.create(client, %{
        "domain" => "example.com",
        "target" => "backup.example.com"
      })

  """

  alias AutoDNS.{BackupMx, Client, Response}

  @base_path "/backupMx"

  @doc "Creates a new BackupMx configuration."
  @spec create(Client.t(), map()) :: {:ok, BackupMx.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(BackupMx)
  end

  @doc "Searches for BackupMx configurations."
  @spec list(Client.t(), map()) :: {:ok, [BackupMx.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(BackupMx)
  end

  @doc "Gets a BackupMx configuration by domain."
  @spec get(Client.t(), String.t()) :: {:ok, BackupMx.t()} | {:error, AutoDNS.Error.t()}
  def get(client, domain) do
    Client.get(client, "#{@base_path}/#{domain}") |> Response.to_struct(BackupMx)
  end

  @doc "Deletes a BackupMx configuration."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, domain) do
    Client.delete(client, "#{@base_path}/#{domain}") |> Response.body()
  end
end
