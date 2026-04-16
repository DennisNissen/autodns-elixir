defmodule AutoDNS.DomainStudio do
  @moduledoc """
  AutoDNS DomainStudio search and classification operations.

  ## Example

      {:ok, results} = AutoDNS.DomainStudio.search(client, %{
        "searchToken" => "example",
        "currency" => "EUR"
      })

  """

  alias AutoDNS.{Client, Response}

  @base_path "/domainstudio"

  @doc "Searches for available domains via DomainStudio."
  @spec search(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def search(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.object()
  end

  @doc "Classifies domains."
  @spec classify(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def classify(client, attrs) do
    Client.post(client, "#{@base_path}/classify", attrs) |> Response.object()
  end

  @doc "Checks social media availability."
  @spec social_media_check(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def social_media_check(client, attrs) do
    Client.post(client, "#{@base_path}/socialmedia", attrs) |> Response.object()
  end

  @doc "Searches for TLDs available in DomainStudio."
  @spec tlds(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def tlds(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/tlds/_search", query) |> Response.data()
  end

  @doc "Gets TLD statistics."
  @spec tld_statistics(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def tld_statistics(client) do
    Client.get(client, "#{@base_path}/tlds/stats/_search") |> Response.body()
  end
end
