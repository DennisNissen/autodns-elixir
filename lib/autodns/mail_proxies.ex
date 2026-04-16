defmodule AutoDNS.MailProxies do
  @moduledoc """
  Operations on AutoDNS mail proxies.

  ## Example

      {:ok, proxy} = AutoDNS.MailProxies.create(client, %{
        "domain" => "example.com",
        "target" => "mail.example.com"
      })

  """

  alias AutoDNS.{Client, MailProxy, Response}

  @base_path "/mailProxy"

  @doc "Creates a new mail proxy."
  @spec create(Client.t(), map()) :: {:ok, MailProxy.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(MailProxy)
  end

  @doc "Searches for mail proxies."
  @spec list(Client.t(), map()) :: {:ok, [MailProxy.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(MailProxy)
  end

  @doc "Gets a mail proxy by domain."
  @spec get(Client.t(), String.t()) :: {:ok, MailProxy.t()} | {:error, AutoDNS.Error.t()}
  def get(client, domain) do
    Client.get(client, "#{@base_path}/#{domain}") |> Response.to_struct(MailProxy)
  end

  @doc "Updates a mail proxy."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, MailProxy.t()} | {:error, AutoDNS.Error.t()}
  def update(client, domain, attrs) do
    Client.put(client, "#{@base_path}/#{domain}", attrs) |> Response.to_struct(MailProxy)
  end

  @doc "Deletes a mail proxy."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, domain) do
    Client.delete(client, "#{@base_path}/#{domain}") |> Response.body()
  end
end
