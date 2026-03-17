defmodule AutoDNS.AccountData do
  @moduledoc "Struct representing AutoDNS account information."
  use AutoDNS.Schema,
    fields: [
      :customer,
      :currentAccountBalance,
      :runningTotal,
      :creditLimit,
      :currency,
      :minRunningTotal,
      :billingUsers,
      :saved,
      :nameServerGroups,
      :notifications,
      :preferences
    ]
end
