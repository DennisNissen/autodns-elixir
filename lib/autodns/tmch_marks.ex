defmodule AutoDNS.TmchMarks do
  @moduledoc """
  Operations on AutoDNS TMCH trademark marks.

  ## Example

      {:ok, marks} = AutoDNS.TmchMarks.list(client)

  """

  alias AutoDNS.{Client, Response, TmchMark}

  @base_path "/tmchMark"

  @doc "Creates a new TMCH mark."
  @spec create(Client.t(), map()) :: {:ok, TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(TmchMark)
  end

  @doc "Imports a TMCH mark."
  @spec import_mark(Client.t(), map()) :: {:ok, TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def import_mark(client, attrs) do
    Client.post(client, "#{@base_path}/_import", attrs) |> Response.to_struct(TmchMark)
  end

  @doc "Searches for TMCH marks."
  @spec list(Client.t(), map()) :: {:ok, [TmchMark.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(TmchMark)
  end

  @doc "Gets a TMCH mark by reference."
  @spec get(Client.t(), String.t()) :: {:ok, TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def get(client, reference) do
    Client.get(client, "#{@base_path}/#{reference}") |> Response.to_struct(TmchMark)
  end

  @doc "Updates a TMCH mark."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def update(client, reference, attrs) do
    Client.put(client, "#{@base_path}/#{reference}", attrs) |> Response.to_struct(TmchMark)
  end

  @doc "Deletes a TMCH mark."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, reference) do
    Client.delete(client, "#{@base_path}/#{reference}") |> Response.body()
  end

  @doc "Confirms a TMCH mark."
  @spec confirm(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm(client, reference, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{reference}/_confirm", attrs) |> Response.body()
  end

  @doc "Transfers a TMCH mark."
  @spec transfer(Client.t(), String.t(), map()) ::
          {:ok, TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def transfer(client, reference, attrs) do
    Client.put(client, "#{@base_path}/#{reference}/_transfer", attrs)
    |> Response.to_struct(TmchMark)
  end

  @doc "Imports and transfers a TMCH mark."
  @spec import_and_transfer(Client.t(), map()) ::
          {:ok, TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def import_and_transfer(client, attrs) do
    Client.post(client, "#{@base_path}/_transfer", attrs) |> Response.to_struct(TmchMark)
  end

  @doc "Creates a document for a TMCH mark."
  @spec create_document(Client.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_document(client, reference, attrs) do
    Client.post(client, "#{@base_path}/#{reference}/document", attrs) |> Response.object()
  end

  @doc "Gets a TMCH mark document."
  @spec get_document(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_document(client, reference, type) do
    Client.get(client, "#{@base_path}/#{reference}/document/#{type}") |> Response.object()
  end

  @doc "Uploads a TMCH mark document."
  @spec upload_document(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def upload_document(client, reference, type, attrs) do
    Client.put(client, "#{@base_path}/#{reference}/document/#{type}", attrs) |> Response.object()
  end

  @doc "Deletes a TMCH mark document."
  @spec delete_document(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_document(client, reference, type) do
    Client.delete(client, "#{@base_path}/#{reference}/document/#{type}") |> Response.body()
  end
end
