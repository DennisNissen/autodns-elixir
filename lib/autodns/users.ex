defmodule AutoDNS.Users do
  @moduledoc """
  Operations on AutoDNS users.

  ## Example

      {:ok, user} = AutoDNS.Users.get(client, "admin", 4)

  """

  alias AutoDNS.Client

  @base_path "/user"

  @doc "Creates a new user."
  @spec create(Client.t(), map()) :: {:ok, AutoDNS.User.t()} | {:error, AutoDNS.Error.t()}
  def create(client, attrs) do
    with {:ok, response} <- Client.post(client, @base_path, attrs) do
      {:ok, AutoDNS.User.from_map(response.object || response.body)}
    end
  end

  @doc "Searches for users."
  @spec list(Client.t(), map()) :: {:ok, [AutoDNS.User.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.User.from_list(response.data || [])}
    end
  end

  @doc "Gets a user by name and context."
  @spec get(Client.t(), String.t(), integer()) ::
          {:ok, AutoDNS.User.t()} | {:error, AutoDNS.Error.t()}
  def get(client, name, context) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{name}/#{context}") do
      {:ok, AutoDNS.User.from_map(response.object || response.body)}
    end
  end

  @doc "Updates a user."
  @spec update(Client.t(), String.t(), integer(), map()) ::
          {:ok, AutoDNS.User.t()} | {:error, AutoDNS.Error.t()}
  def update(client, name, context, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/#{context}", attrs) do
      {:ok, AutoDNS.User.from_map(response.object || response.body)}
    end
  end

  @doc "Deletes a user."
  @spec delete(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def delete(client, name, context) do
    with {:ok, response} <- Client.delete(client, "#{@base_path}/#{name}/#{context}") do
      {:ok, response.body}
    end
  end

  @doc "Locks a user."
  @spec lock(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def lock(client, name, context) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/#{context}/_lock") do
      {:ok, response.body}
    end
  end

  @doc "Unlocks a user."
  @spec unlock(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def unlock(client, name, context) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/#{context}/_unlock") do
      {:ok, response.body}
    end
  end

  @doc "Resends the invitation email to a user."
  @spec resend_invite(Client.t(), String.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_invite(client, name, context) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{context}/_resendInvite") do
      {:ok, response.body}
    end
  end

  @doc "Gets a user's ACL."
  @spec get_acl(Client.t(), String.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_acl(client, name, context) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{name}/#{context}/acl") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Updates a user's ACL."
  @spec update_acl(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_acl(client, name, context, attrs) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{name}/#{context}/acl", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Gets a user's profile."
  @spec get_profile(Client.t(), String.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_profile(client, name, context) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{name}/#{context}/profile") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Updates a user's profile."
  @spec update_profile(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_profile(client, name, context, attrs) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{context}/profile", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Gets a user's profile with a specific prefix."
  @spec get_profile_with_prefix(Client.t(), String.t(), integer(), String.t()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def get_profile_with_prefix(client, name, context, prefix) do
    with {:ok, response} <-
           Client.get(client, "#{@base_path}/#{name}/#{context}/profile/#{prefix}") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Updates a user's service profile."
  @spec update_service_profile(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def update_service_profile(client, name, context, attrs) do
    with {:ok, response} <-
           Client.put(client, "#{@base_path}/#{name}/#{context}/serviceProfile", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Creates SSO for a user."
  @spec create_sso(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_sso(client, name, context, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{name}/#{context}/sso", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Copies a user."
  @spec copy(Client.t(), String.t(), integer(), map()) ::
          {:ok, AutoDNS.User.t()} | {:error, AutoDNS.Error.t()}
  def copy(client, name, context, attrs \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/#{name}/#{context}/copy", attrs) do
      {:ok, AutoDNS.User.from_map(response.object || response.body)}
    end
  end

  @doc "Creates a verification for a user."
  @spec create_verification(Client.t(), String.t(), integer(), map()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def create_verification(client, name, context, attrs \\ %{}) do
    with {:ok, response} <-
           Client.post(client, "#{@base_path}/#{name}/#{context}/verification", attrs) do
      {:ok, response.object || response.body}
    end
  end

  @doc "Gets billing limit info."
  @spec billing_limit(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def billing_limit(client) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/billinglimit") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Gets billing term info."
  @spec billing_term(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def billing_term(client) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/billingterm") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Gets task limit info."
  @spec task_limit(Client.t()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def task_limit(client) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/tasklimit") do
      {:ok, response.object || response.body}
    end
  end

  @doc "Lists sales reports."
  @spec sales_report_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def sales_report_list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/salesreport/_search", query) do
      {:ok, response.data || []}
    end
  end
end
