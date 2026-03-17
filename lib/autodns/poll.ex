defmodule AutoDNS.Poll do
  @moduledoc "Struct representing an AutoDNS poll message."
  use AutoDNS.Schema,
    fields: [
      :id,
      :owner,
      :job,
      :notify,
      :stid,
      :messages,
      :object,
      :created,
      :updated
    ]
end
