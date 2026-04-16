defmodule AutoDNS.Certificates do
  @moduledoc """
  Operations on AutoDNS SSL certificates.

  ## Example

      {:ok, cert} = AutoDNS.Certificates.create(client, %{
        "name" => "example.com",
        "product" => "POSITIVE_SSL",
        "csr" => "-----BEGIN CERTIFICATE REQUEST-----..."
      })

  """

  alias AutoDNS.{Certificate, Client, Response}

  @base_path "/certificate"

  @doc "Creates a new certificate order."
  @spec create(Client.t(), map()) :: {:ok, Certificate.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(Certificate)
  end

  @doc "Creates a realtime certificate."
  @spec create_realtime(Client.t(), map()) ::
          {:ok, Certificate.t()} | {:error, AutoDNS.Error.t()}
  def create_realtime(client, attrs) do
    Client.post(client, "#{@base_path}/_realtime", attrs) |> Response.to_struct(Certificate)
  end

  @doc "Prepares a certificate order."
  @spec prepare_order(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def prepare_order(client, attrs) do
    Client.post(client, "#{@base_path}/_prepareOrder", attrs) |> Response.object()
  end

  @doc "Searches for certificates."
  @spec list(Client.t(), map()) :: {:ok, [Certificate.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Certificate)
  end

  @doc "Gets a certificate by ID."
  @spec get(Client.t(), integer()) :: {:ok, Certificate.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    Client.get(client, "#{@base_path}/#{id}") |> Response.to_struct(Certificate)
  end

  @doc "Deletes (cancels) a certificate."
  @spec delete(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, id) do
    Client.delete(client, "#{@base_path}/#{id}") |> Response.body()
  end

  @doc "Reissues a certificate."
  @spec reissue(Client.t(), integer(), map()) ::
          {:ok, Certificate.t()} | {:error, AutoDNS.Error.t()}
  def reissue(client, id, attrs) do
    Client.put(client, "#{@base_path}/#{id}", attrs) |> Response.to_struct(Certificate)
  end

  @doc "Renews a certificate."
  @spec renew(Client.t(), integer(), map()) ::
          {:ok, Certificate.t()} | {:error, AutoDNS.Error.t()}
  def renew(client, id, attrs \\ %{}) do
    Client.put(client, "#{@base_path}/#{id}/_renew", attrs) |> Response.to_struct(Certificate)
  end

  @doc "Revokes a certificate."
  @spec revoke(Client.t(), integer(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def revoke(client, id, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{id}/_revoke", attrs) |> Response.body()
  end

  @doc "Updates a certificate's comment."
  @spec update_comment(Client.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, id, attrs) do
    Client.put(client, "#{@base_path}/#{id}/_comment", attrs) |> Response.body()
  end

  @doc "Gets the site seal for a certificate."
  @spec site_seal(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def site_seal(client, id) do
    Client.get(client, "#{@base_path}/#{id}/_siteseal") |> Response.object()
  end

  @doc "Runs an installation check for a certificate."
  @spec install_check(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def install_check(client, attrs) do
    Client.post(client, "#{@base_path}/_installcheck", attrs) |> Response.object()
  end

  @doc "Checks VMC data for a certificate."
  @spec check_vmc_data(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def check_vmc_data(client, attrs) do
    Client.post(client, "#{@base_path}/_checkVmcData", attrs) |> Response.object()
  end
end
