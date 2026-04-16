defmodule AutoDNS.Session do
  @moduledoc """
  AutoDNS session management.

  ## Example

      {:ok, session} = AutoDNS.Session.login(client)
      :ok = AutoDNS.Session.logout(client)

  """

  alias AutoDNS.{AuthSession, Client, Response}

  @doc "Creates a new session (login)."
  @spec login(Client.t(), map()) :: {:ok, AuthSession.t()} | {:error, AutoDNS.Error.t()}
  def login(client, attrs \\ %{}) do
    Client.post(client, "/login", attrs) |> Response.to_struct(AuthSession)
  end

  @doc "Ends the current session (logout via GET)."
  @spec logout(Client.t()) :: :ok | {:error, AutoDNS.Error.t()}
  def logout(client) do
    case Client.get(client, "/logout") do
      {:ok, _} -> :ok
      {:error, _} = error -> error
    end
  end

  @doc "Deletes the current session (logout via DELETE)."
  @spec delete(Client.t()) :: :ok | {:error, AutoDNS.Error.t()}
  def delete(client) do
    case Client.delete(client, "/logout") do
      {:ok, _} -> :ok
      {:error, _} = error -> error
    end
  end
end
