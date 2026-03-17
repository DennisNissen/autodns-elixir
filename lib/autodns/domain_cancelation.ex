defmodule AutoDNS.DomainCancelation do
  @moduledoc "Struct representing an AutoDNS domain cancelation."
  use AutoDNS.Schema,
    fields: [
      :domain,
      :registryStatus,
      :type,
      :execution,
      :registryWhen,
      :disconnect,
      :notice,
      :logId,
      :owner,
      :updater,
      :created,
      :updated
    ]
end
