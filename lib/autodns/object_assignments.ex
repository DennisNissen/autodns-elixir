defmodule AutoDNS.ObjectAssignments do
  @moduledoc """
  Operations on AutoDNS object-user assignments.

  ## Example

      {:ok, result} = AutoDNS.ObjectAssignments.assign(client, %{
        "objects" => [%{"type" => "DOMAIN", "value" => "example.com"}],
        "user" => %{"user" => "admin", "context" => 4}
      })

  """

  alias AutoDNS.Client

  @doc "Assigns objects to a user."
  @spec assign(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def assign(client, attrs) do
    with {:ok, response} <- Client.put(client, "/object/_assignment", attrs) do
      {:ok, response.body}
    end
  end

  @doc "Assigns all objects to a user."
  @spec assign_all(Client.t(), map()) :: {:ok, map()} | {:error, AutoDNS.Error.t()}
  def assign_all(client, attrs) do
    with {:ok, response} <- Client.put(client, "/object/_assignment/all", attrs) do
      {:ok, response.body}
    end
  end
end
