defmodule AutoDNS.DomainPrereg do
  @moduledoc "Struct representing an AutoDNS domain pre-registration."
  use AutoDNS.Schema,
    fields: [
      :reference,
      :name,
      :idn,
      :ace,
      :status,
      :domain,
      :preregConfig,
      :ownerc,
      :adminc,
      :techc,
      :zonec,
      :nameServers,
      :period,
      :trustee,
      :privacy,
      :extensions,
      :comment,
      :confirmOrder,
      :confirmOwnerConsent,
      :owner,
      :updater,
      :created,
      :updated,
      :logId
    ]
end
