defmodule AutoDNS.DomainPreregs do
  @moduledoc """
  Operations on AutoDNS domain pre-registrations.

  ## Example

      {:ok, prereg} = AutoDNS.DomainPreregs.create(client, %{
        "name" => "example.new",
        "ownerc" => %{"fname" => "John", "lname" => "Doe"}
      })

  """

  alias AutoDNS.{Client, DomainPrereg, Response}

  @base_path "/domainPrereg"

  @doc "Creates a new domain pre-registration."
  @spec create(Client.t(), map()) :: {:ok, DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(DomainPrereg)
  end

  @doc "Creates and confirms a pre-registration in one step."
  @spec create_and_confirm(Client.t(), map()) ::
          {:ok, DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def create_and_confirm(client, attrs) do
    Client.post(client, "#{@base_path}/_confirm", attrs) |> Response.to_struct(DomainPrereg)
  end

  @doc "Searches for domain pre-registrations."
  @spec list(Client.t(), map()) :: {:ok, [DomainPrereg.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(DomainPrereg)
  end

  @doc "Gets a domain pre-registration by reference."
  @spec get(Client.t(), String.t()) :: {:ok, DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def get(client, reference) do
    Client.get(client, "#{@base_path}/#{reference}") |> Response.to_struct(DomainPrereg)
  end

  @doc "Updates a domain pre-registration."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def update(client, reference, attrs) do
    Client.put(client, "#{@base_path}/#{reference}", attrs) |> Response.to_struct(DomainPrereg)
  end

  @doc "Deletes a domain pre-registration."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, reference) do
    Client.delete(client, "#{@base_path}/#{reference}") |> Response.body()
  end

  @doc "Confirms a domain pre-registration."
  @spec confirm(Client.t(), String.t(), map()) ::
          {:ok, DomainPrereg.t()} | {:error, AutoDNS.Error.t()}
  def confirm(client, reference, attrs \\ %{}) do
    Client.put(client, "#{@base_path}/#{reference}/_confirm", attrs)
    |> Response.to_struct(DomainPrereg)
  end
end
