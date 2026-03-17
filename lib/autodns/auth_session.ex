defmodule AutoDNS.AuthSession do
  @moduledoc "Struct representing an AutoDNS authentication session."
  use AutoDNS.Schema,
    fields: [
      :session,
      :user,
      :context,
      :created,
      :updated,
      :language
    ]
end
