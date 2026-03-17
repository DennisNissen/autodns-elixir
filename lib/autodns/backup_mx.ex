defmodule AutoDNS.BackupMx do
  @moduledoc "Struct representing an AutoDNS BackupMx configuration."
  use AutoDNS.Schema,
    fields: [
      :domain,
      :idn,
      :status,
      :target,
      :owner,
      :updated
    ]
end
