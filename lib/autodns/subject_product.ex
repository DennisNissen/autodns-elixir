defmodule AutoDNS.SubjectProduct do
  @moduledoc "Struct representing an AutoDNS subject product."
  use AutoDNS.Schema,
    fields: [
      :id,
      :name,
      :type,
      :category,
      :classification,
      :priceClass,
      :period,
      :billingTerm,
      :configuration,
      :owner,
      :updater,
      :created,
      :updated
    ]
end
