defmodule AutoDNS.Invoice do
  @moduledoc "Struct representing an AutoDNS invoice."
  use AutoDNS.Schema,
    fields: [
      :id,
      :number,
      :customer,
      :payment,
      :paymentMode,
      :paymentTransaction,
      :subType,
      :status,
      :type,
      :currency,
      :amount,
      :vat,
      :net,
      :period,
      :taxable,
      :separator,
      :document,
      :comments,
      :created,
      :updated,
      :owner,
      :updater,
      :logId
    ]
end
