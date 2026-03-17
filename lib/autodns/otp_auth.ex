defmodule AutoDNS.OTPAuthData do
  @moduledoc "Struct representing AutoDNS OTP/2FA authentication data."
  use AutoDNS.Schema,
    fields: [
      :protocol,
      :algorithm,
      :digits,
      :period,
      :secretSize,
      :secret,
      :qrCode,
      :tokens
    ]
end
