defmodule AutoDNS.Contacts do
  @moduledoc """
  Operations on AutoDNS contacts.

  Contacts are used as domain registrant (ownerc), admin (adminc),
  technical (techc), and zone (zonec) contacts.

  ## Example

      {:ok, contact} = AutoDNS.Contacts.create(client, %{
        "type" => "PERSON",
        "fname" => "John",
        "lname" => "Doe",
        "email" => "john@example.com",
        "address" => ["123 Main St"],
        "city" => "Berlin",
        "country" => "DE",
        "pcode" => "10115"
      })

  """

  alias AutoDNS.{Client, Contact, Response}

  @base_path "/contact"

  @doc "Creates a new contact."
  @spec create(Client.t(), map()) :: {:ok, Contact.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(Contact)
  end

  @doc "Searches for contacts."
  @spec list(Client.t(), map()) :: {:ok, [Contact.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Contact)
  end

  @doc "Gets a contact by ID."
  @spec get(Client.t(), integer()) :: {:ok, Contact.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    Client.get(client, "#{@base_path}/#{id}") |> Response.to_struct(Contact)
  end

  @doc "Updates a contact."
  @spec update(Client.t(), integer(), map()) ::
          {:ok, Contact.t()} | {:error, AutoDNS.Error.t()}
  def update(client, id, attrs) do
    Client.put(client, "#{@base_path}/#{id}", attrs) |> Response.to_struct(Contact)
  end

  @doc "Deletes a contact."
  @spec delete(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, id) do
    Client.delete(client, "#{@base_path}/#{id}") |> Response.body()
  end

  @doc "Updates a contact's comment."
  @spec update_comment(Client.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, id, attrs) do
    Client.put(client, "#{@base_path}/#{id}/_comment", attrs) |> Response.body()
  end

  @doc "Adds a contact to DomainSafe."
  @spec add_domain_safe(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def add_domain_safe(client, id) do
    Client.put(client, "#{@base_path}/#{id}/_domainSafe") |> Response.body()
  end

  @doc "Removes a contact from DomainSafe."
  @spec delete_domain_safe(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_domain_safe(client, id) do
    Client.delete(client, "#{@base_path}/#{id}/_domainSafe") |> Response.body()
  end

  @doc "Restores a contact."
  @spec restore(Client.t(), integer(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def restore(client, id, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{id}/_restore", attrs) |> Response.body()
  end

  @doc "Gets verification status for a contact."
  @spec get_verification(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_verification(client, id) do
    Client.get(client, "#{@base_path}/#{id}/verification") |> Response.object()
  end

  @doc "Creates a verification for a contact."
  @spec create_verification(Client.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_verification(client, id, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{id}/verification", attrs) |> Response.object()
  end

  @doc "Resends verification email for a contact."
  @spec resend_verification_email(Client.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_verification_email(client, id) do
    Client.put(client, "#{@base_path}/#{id}/verification/_resendEmail") |> Response.body()
  end

  @doc "Gets verification info with reference."
  @spec verification_info(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def verification_info(client) do
    Client.get(client, "#{@base_path}/verification") |> Response.object()
  end

  @doc "Confirms a verification."
  @spec confirm_verification(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm_verification(client, attrs) do
    Client.put(client, "#{@base_path}/verification/_confirm", attrs) |> Response.body()
  end

  @doc "Lists verifications."
  @spec list_verifications(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_verifications(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/verification/_search", query) |> Response.data()
  end

  @doc "Lists verification history."
  @spec list_verification_history(Client.t(), map()) ::
          {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_verification_history(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/verification/history/_search", query) |> Response.data()
  end

  @doc "Gets verification history info."
  @spec verification_history_info(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def verification_history_info(client) do
    Client.get(client, "#{@base_path}/verification/history") |> Response.object()
  end
end
