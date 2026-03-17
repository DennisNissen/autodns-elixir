defmodule AutoDNS.TmchMarks do
  @moduledoc """
  Operations on AutoDNS TMCH trademark marks.

  ## Example

      {:ok, marks} = AutoDNS.TmchMarks.list(client)

  """

  alias AutoDNS.Client

  @base_path "/tmchMark"

  @doc "Creates a new TMCH mark."
  @spec create(Client.t(), map()) ::
          {:ok, AutoDNS.TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.TmchMark.from_map(response.object || response.body)}
    end
  end

  @doc "Imports a TMCH mark."
  @spec import_mark(Client.t(), map()) ::
          {:ok, AutoDNS.TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def import_mark(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_import", attrs) do
      {:ok, AutoDNS.TmchMark.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for TMCH marks."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.TmchMark.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.TmchMark.from_list(response.data || [])}
    end
  end

  @doc "Gets a TMCH mark by reference."
  @spec get(Client.t(), String.t()) ::
          {:ok, AutoDNS.TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def get(client, reference) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{reference}") do
      {:ok, AutoDNS.TmchMark.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a TMCH mark."
  @spec update(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def update(client, reference, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{reference}", attrs) do
      {:ok, AutoDNS.TmchMark.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a TMCH mark."
  @spec delete(Client.t(), String.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, reference) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{reference}") do
      {:ok, response.body}
    end
  end

  @doc "Confirms a TMCH mark."
  @spec confirm(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm(client, reference, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{reference}/_confirm", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Transfers a TMCH mark."
  @spec transfer(Client.t(), String.t(), map()) ::
          {:ok, AutoDNS.TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def transfer(client, reference, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{reference}/_transfer", attrs) do
      {:ok, AutoDNS.TmchMark.from_map(response.object || response.body)}
    end
  end

  @doc "Imports and transfers a TMCH mark."
  @spec import_and_transfer(Client.t(), map()) ::
          {:ok, AutoDNS.TmchMark.t()} | {:error, AutoDNS.Error.t()}
  def import_and_transfer(client, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_transfer", attrs) do
      {:ok, AutoDNS.TmchMark.from_map(response.object || response.body)}
    end
  end

  @doc "Creates a document for a TMCH mark."
  @spec create_document(Client.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_document(client, reference, attrs) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{reference}/document", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Gets a TMCH mark document."
  @spec get_document(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_document(client, reference, type) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{reference}/document/#{type}") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Uploads a TMCH mark document."
  @spec upload_document(Client.t(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def upload_document(client, reference, type, attrs) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{reference}/document/#{type}", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Deletes a TMCH mark document."
  @spec delete_document(Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_document(client, reference, type) do
    with {:ok, response} <-
           Client.delete(client, "#{@base_path}/#{reference}/document/#{type}") do
      {:ok, response.body}
    end
  end
end
