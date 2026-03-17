defmodule AutoDNS.TransferOut do
  @moduledoc "Struct representing an AutoDNS outgoing transfer."
  use AutoDNS.Schema,
    fields: [
      :domain,
      :status,
      :type,
      :nackReason,
      :start,
      :reminder,
      :autoAck,
      :autoNack,
      :registrar,
      :gaining,
      :losing,
      :transit,
      :owner,
      :updater,
      :created,
      :updated,
      :logId
    ]
end
