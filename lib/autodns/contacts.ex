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

  alias AutoDNS.Client

  @base_path "/contact"

  @doc "Creates a new contact."
  @spec create(Client.t(), map()) :: {:ok, AutoDNS.Contact.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.Contact.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for contacts."
  @spec list(Client.t(), map()) :: {:ok, [AutoDNS.Contact.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Contact.from_list(response.data || [])}
    end
  end

  @doc "Gets a contact by ID."
  @spec get(Client.t(), integer()) :: {:ok, AutoDNS.Contact.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{id}") do
      {:ok, AutoDNS.Contact.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a contact."
  @spec update(Client.t(), integer(), map()) ::
          {:ok, AutoDNS.Contact.t()} | {:error, AutoDNS.Error.t()}
  def update(client, id, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}", attrs) do
      {:ok, AutoDNS.Contact.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a contact."
  @spec delete(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, id) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{id}") do
      {:ok, response.body}
    end
  end

  @doc "Updates a contact's comment."
  @spec update_comment(Client.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_comment(client, id, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}/_comment", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Adds a contact to DomainSafe."
  @spec add_domain_safe(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def add_domain_safe(client, id) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}/_domainSafe") do
      {:ok, response.body}
    end
  end

  @doc "Removes a contact from DomainSafe."
  @spec delete_domain_safe(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete_domain_safe(client, id) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{id}/_domainSafe") do
      {:ok, response.body}
    end
  end

  @doc "Restores a contact."
  @spec restore(Client.t(), integer(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def restore(client, id, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{id}/_restore", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Gets verification status for a contact."
  @spec get_verification(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_verification(client, id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{id}/verification") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Creates a verification for a contact."
  @spec create_verification(Client.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_verification(client, id, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{id}/verification", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Resends verification email for a contact."
  @spec resend_verification_email(Client.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_verification_email(client, id) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{id}/verification/_resendEmail") do
      {:ok, response.body}
    end
  end

  @doc "Gets verification info with reference."
  @spec verification_info(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def verification_info(client) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/verification") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Confirms a verification."
  @spec confirm_verification(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm_verification(client, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/verification/_confirm", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Lists verifications."
  @spec list_verifications(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_verifications(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/verification/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Lists verification history."
  @spec list_verification_history(Client.t(), map()) ::
          {:ok, list()} | {:error, AutoDNS.Error.t()}
  def list_verification_history(client, query \\ %{}) do
    with {:ok, response} <-
           Client.post(client, "#{@base_path}/verification/history/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Gets verification history info."
  @spec verification_history_info(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def verification_history_info(client) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/verification/history") do
      {:ok, response.object || response.body}
    end
  end
end
