defmodule AutoDNS.TmchMark do
  @moduledoc "Struct representing an AutoDNS TMCH trademark mark."
  use AutoDNS.Schema,
    fields: [
      :reference,
      :name,
      :type,
      :status,
      :smdInclusion,
      :claimsNotify,
      :goodsAndServices,
      :labels,
      :period,
      :holder,
      :contacts,
      :documents,
      :trademark,
      :court,
      :treatyOrStatute,
      :comment,
      :agtDocId,
      :notBefore,
      :notAfter,
      :smdFile,
      :owner,
      :updater,
      :created,
      :updated,
      :logId
    ]
end
