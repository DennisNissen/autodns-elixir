defmodule AutoDNS.Redirect do
  @moduledoc "Struct representing an AutoDNS redirect."
  use AutoDNS.Schema,
    fields: [
      :source,
      :target,
      :type,
      :mode,
      :domain,
      :title,
      :backups,
      :sourceIdn,
      :targetIdn,
      :lastSeen,
      :status,
      :owner,
      :updater,
      :created,
      :updated,
      :logId
    ]
end
