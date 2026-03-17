defmodule AutoDNS.Job do
  @moduledoc "Struct representing an AutoDNS job."
  use AutoDNS.Schema,
    fields: [
      :id,
      :status,
      :type,
      :subType,
      :action,
      :execution,
      :display,
      :domain,
      :certificate,
      :contact,
      :zone,
      :redirect,
      :mailProxy,
      :owner,
      :updater,
      :created,
      :updated
    ]
end
