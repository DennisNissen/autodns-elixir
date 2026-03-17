defmodule AutoDNS.TmchClaim do
  @moduledoc "Struct representing an AutoDNS TMCH claims notice."
  use AutoDNS.Schema,
    fields: [
      :reference,
      :domain,
      :status,
      :claimsNotice,
      :owner,
      :updater,
      :created,
      :updated,
      :logId
    ]
end
