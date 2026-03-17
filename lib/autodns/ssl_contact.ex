defmodule AutoDNS.SslContact do
  @moduledoc "Struct representing an AutoDNS SSL contact."
  use AutoDNS.Schema,
    fields: [
      :id,
      :fname,
      :lname,
      :phone,
      :fax,
      :email,
      :title,
      :organization,
      :address,
      :pcode,
      :city,
      :country,
      :state,
      :owner,
      :updater,
      :created,
      :updated,
      :comment,
      :logId
    ]
end
