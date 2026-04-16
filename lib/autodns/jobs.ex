defmodule AutoDNS.Jobs do
  @moduledoc """
  Operations on AutoDNS jobs.

  Jobs represent asynchronous operations like domain registrations,
  transfers, and certificate orders.

  ## Example

      {:ok, jobs} = AutoDNS.Jobs.list(client)
      {:ok, job} = AutoDNS.Jobs.get(client, 12345)

  """

  alias AutoDNS.{Client, Job, Response}

  @base_path "/job"

  @doc "Searches for jobs."
  @spec list(Client.t(), map()) :: {:ok, [Job.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/_search", query) |> Response.to_list(Job)
  end

  @doc "Gets a job by ID."
  @spec get(Client.t(), integer()) :: {:ok, Job.t()} | {:error, AutoDNS.Error.t()}
  def get(client, id) do
    Client.get(client, "#{@base_path}/#{id}") |> Response.to_struct(Job)
  end

  @doc "Cancels a job."
  @spec cancel(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def cancel(client, id) do
    Client.put(client, "#{@base_path}/#{id}/_cancel") |> Response.body()
  end

  @doc "Confirms a job."
  @spec confirm(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def confirm(client, id) do
    Client.put(client, "#{@base_path}/#{id}/_confirm") |> Response.body()
  end

  @doc "Resends the approver email for a certificate job."
  @spec resend_approver_email(Client.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_approver_email(client, id) do
    Client.put(client, "#{@base_path}/#{id}/_resendApproverEmail") |> Response.body()
  end

  @doc "Resends phone authorization for a job."
  @spec resend_phone_authorization(Client.t(), integer()) ::
          {:ok, map()} | {:error, AutoDNS.Error.t()}
  def resend_phone_authorization(client, id) do
    Client.put(client, "#{@base_path}/#{id}/_resendPhoneAuthorization") |> Response.body()
  end

  @doc "Searches job history."
  @spec history_list(Client.t(), map()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def history_list(client, query \\ %{}) do
    Client.post(client, "#{@base_path}/history/_search", query) |> Response.data()
  end

  @doc "Gets a job history entry by ID."
  @spec history_get(Client.t(), integer()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def history_get(client, id) do
    Client.get(client, "#{@base_path}/history/#{id}") |> Response.object()
  end
end
