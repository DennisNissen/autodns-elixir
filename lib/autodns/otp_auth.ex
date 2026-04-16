defmodule AutoDNS.OTPAuth do
  @moduledoc """
  Operations on AutoDNS OTP/2FA authentication.

  ## Example

      {:ok, otp_config} = AutoDNS.OTPAuth.get(client)
      {:ok, otp_token} = AutoDNS.OTPAuth.create(client)

  """

  alias AutoDNS.{Client, OTPAuthData, Response}

  @doc "Gets the OTP authentication configuration for the logged-in user."
  @spec get(Client.t()) :: {:ok, OTPAuthData.t()} | {:error, AutoDNS.Error.t()}
  def get(client) do
    Client.get(client, "/OTPAuth") |> Response.to_struct(OTPAuthData)
  end

  @doc "Creates a temporary OTP token for the logged-in user."
  @spec create(Client.t()) :: {:ok, OTPAuthData.t()} | {:error, AutoDNS.Error.t()}
  def create(client) do
    Client.post(client, "/OTPAuth") |> Response.to_struct(OTPAuthData)
  end
end
