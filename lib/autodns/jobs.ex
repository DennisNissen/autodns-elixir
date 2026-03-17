defmodule AutoDNS.Jobs do
  @moduledoc """
  Operations on AutoDNS jobs.

  Jobs represent asynchronous operations like domain registrations,
  transfers, and certificate orders.

  ## Example

      {:ok, jobs} = AutoDNS.Jobs.list(client)
      {:ok, job} = AutoDNS.Jobs.get(client, 12345)

  """

  alias AutoDNS.Client

  @base_path "/job"

  @doc "Searches for jobs."
  @spec list(Client.t(), map()) :: {:ok, [AutoDNS.Job.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/_search", query) do
      {:ok, AutoDNS.Job.from_list(response.data || [])}
    end
  end

  @doc "Gets a job by ID."
  @spec get(Client.t(), integer()) :: {:ok, AutoDNS.Job.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/#{id}") do
      {:ok, AutoDNS.Job.from_map(response.object || response.body)}
    end
  end

  @doc "Cancels a job."
  @spec cancel(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def cancel(client, id) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}/_cancel") do
      {:ok, response.body}
    end
  end

  @doc "Confirms a job."
  @spec confirm(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm(client, id) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}/_confirm") do
      {:ok, response.body}
    end
  end

  @doc "Resends the approver email for a certificate job."
  @spec resend_approver_email(Client.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_approver_email(client, id) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}/_resendApproverEmail") do
      {:ok, response.body}
    end
  end

  @doc "Resends phone authorization for a job."
  @spec resend_phone_authorization(Client.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_phone_authorization(client, id) do
    with {:ok, response} <- Client.put(client, "#{@base_path}/#{id}/_resendPhoneAuthorization") do
      {:ok, response.body}
    end
  end

  @doc "Searches job history."
  @spec history_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def history_list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "#{@base_path}/history/_search", query) do
      {:ok, response.data || []}
    end
  end

  @doc "Gets a job history entry by ID."
  @spec history_get(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def history_get(client, id) do
    with {:ok, response} <- Client.get(client, "#{@base_path}/history/#{id}") do
      {:ok, response.object || response.body}
    end
  end
end
