defmodule AutoDNS.Subscription do
  @moduledoc "Struct representing an AutoDNS subscription."
  use AutoDNS.Schema,
    fields: [
      :contractId,
      :object,
      :article,
      :billing,
      :limits,
      :description,
      :status,
      :variant,
      :period,
      :renewalDate,
      :paymentMode,
      :restrictions,
      :extensions,
      :owner,
      :updater,
      :created,
      :updated,
      :logId,
      :currency,
      :prices,
      :priceChanges,
      :cancelation,
      :upgrade,
      :features
    ]
end
