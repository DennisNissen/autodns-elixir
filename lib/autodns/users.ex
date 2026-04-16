defmodule AutoDNS.Users do
  @moduledoc """
  Operations on AutoDNS users.

  ## Example

      {:ok, user} = AutoDNS.Users.get(client, "admin", 4)

  """

  alias AutoDNS.{Client, Response, User}

  @base_path "/user"

  @doc "Creates a new user."
  @spec create(Client.t(), map()) :: {:ok, User.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    Client.post(client, @base_path, attrs) |> Response.to_struct(User)
  end

  @doc "Searches for users."
  @spec list(Client.t(), map()) :: {:ok, [User.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(User)
  end

  @doc "Gets a user by name and context."
  @spec get(Client.t(), String.t(), integer()) ::
          {:ok, User.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name, context) do
    Client.get(client, "#{@base_path}/#{name}/#{context}") |> Response.to_struct(User)
  end

  @doc "Updates a user."
  @spec update(Client.t(), String.t(), integer(), map()) ::
          {:ok, User.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, context, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{context}", attrs) |> Response.to_struct(User)
  end

  @doc "Deletes a user."
  @spec delete(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name, context) do
    Client.delete(client, "#{@base_path}/#{name}/#{context}") |> Response.body()
  end

  @doc "Locks a user."
  @spec lock(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def lock(client, name, context) do
    Client.put(client, "#{@base_path}/#{name}/#{context}/_lock") |> Response.body()
  end

  @doc "Unlocks a user."
  @spec unlock(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def unlock(client, name, context) do
    Client.put(client, "#{@base_path}/#{name}/#{context}/_unlock") |> Response.body()
  end

  @doc "Resends the invitation email to a user."
  @spec resend_invite(Client.t(), String.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_invite(client, name, context) do
    Client.put(client, "#{@base_path}/#{name}/#{context}/_resendInvite") |> Response.body()
  end

  @doc "Gets a user's ACL."
  @spec get_acl(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_acl(client, name, context) do
    Client.get(client, "#{@base_path}/#{name}/#{context}/acl") |> Response.object()
  end

  @doc "Updates a user's ACL."
  @spec update_acl(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_acl(client, name, context, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{context}/acl", attrs) |> Response.body()
  end

  @doc "Gets a user's profile."
  @spec get_profile(Client.t(), String.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_profile(client, name, context) do
    Client.get(client, "#{@base_path}/#{name}/#{context}/profile") |> Response.object()
  end

  @doc "Updates a user's profile."
  @spec update_profile(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_profile(client, name, context, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{context}/profile", attrs) |> Response.body()
  end

  @doc "Gets a user's profile with a specific prefix."
  @spec get_profile_with_prefix(Client.t(), String.t(), integer(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_profile_with_prefix(client, name, context, prefix) do
    Client.get(client, "#{@base_path}/#{name}/#{context}/profile/#{prefix}") |> Response.object()
  end

  @doc "Updates a user's service profile."
  @spec update_service_profile(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_service_profile(client, name, context, attrs) do
    Client.put(client, "#{@base_path}/#{name}/#{context}/serviceProfile", attrs)
    |> Response.body()
  end

  @doc "Creates SSO for a user."
  @spec create_sso(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_sso(client, name, context, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{name}/#{context}/sso", attrs) |> Response.object()
  end

  @doc "Copies a user."
  @spec copy(Client.t(), String.t(), integer(), map()) ::
          {:ok, User.t()} | {:error, AutoDNS.Error.t()}
  def copy(client, name, context, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{name}/#{context}/copy", attrs) |> Response.to_struct(User)
  end

  @doc "Creates a verification for a user."
  @spec create_verification(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_verification(client, name, context, attrs \\ %{}) do
    Client.post(client, "#{@base_path}/#{name}/#{context}/verification", attrs)
    |> Response.object()
  end

  @doc "Gets billing limit info."
  @spec billing_limit(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def billing_limit(client) do
    Client.get(client, "#{@base_path}/billinglimit") |> Response.object()
  end

  @doc "Gets billing term info."
  @spec billing_term(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def billing_term(client) do
    Client.get(client, "#{@base_path}/billingterm") |> Response.object()
  end

  @doc "Gets task limit info."
  @spec task_limit(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def task_limit(client) do
    Client.get(client, "#{@base_path}/tasklimit") |> Response.object()
  end

  @doc "Lists sales reports."
  @spec sales_report_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def sales_report_list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/salesreport/_search", query) |> Response.data()
  end
end
