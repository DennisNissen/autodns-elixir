defmodule AutoDNS.OTPAuth do
  @moduledoc """
  Operations on AutoDNS OTP/2FA authentication.

  ## Example

      {:ok, otp_config} = AutoDNS.OTPAuth.get(client)
      {:ok, otp_token} = AutoDNS.OTPAuth.create(client)

  """

  alias AutoDNS.Client

  @doc "Gets the OTP authentication configuration for the logged-in user."
  @spec get(Client.t()) :: {:ok, AutoDNS.OTPAuthData.t()} | {:error, AutoDNS.Error.t()}
  def get(client) do
    with {:ok, response} <- Client.get(client, "/OTPAuth") do
      {:ok, AutoDNS.OTPAuthData.from_map(response.object || response.body)}
    end
  end

  @doc "Creates a temporary OTP token for the logged-in user."
  @spec create(Client.t()) :: {:ok, AutoDNS.OTPAuthData.t()} | {:error, AutoDNS.Error.t()}
  def create(client) do
    with {:ok, response} <- Client.post(client, "/OTPAuth") do
      {:ok, AutoDNS.OTPAuthData.from_map(response.object || response.body)}
    end
  end
end
