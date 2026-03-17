defmodule AutoDNS.MailProxies do
  @moduledoc """
  Operations on AutoDNS mail proxies.

  ## Example

      {:ok, proxy} = AutoDNS.MailProxies.create(client, %{
        "domain" => "example.com",
        "target" => "mail.example.com"
      })

  """

  alias AutoDNS.Client

  @base_path "/mailProxy"

  @doc "Creates a new mail proxy."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.MailProxy.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.MailProxy.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for mail proxies."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.MailProxy.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.MailProxy.from_list(response.data || [])}
    end
  end

  @doc "Gets a mail proxy by domain."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.MailProxy.t()} | {:error, AutoDNS.Error.t()}
  def get(client, domain) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{domain}") do
      {:ok, AutoDNS.MailProxy.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a mail proxy."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.MailProxy.t()} | {:error, AutoDNS.Error.t()}
  def update(client, domain, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{domain}", attrs) do
      {:ok, AutoDNS.MailProxy.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a mail proxy."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, domain) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{domain}") do
      {:ok, response.body}
    end
  end
end
