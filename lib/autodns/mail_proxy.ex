defmodule AutoDNS.MailProxy do
  @moduledoc "Struct representing an AutoDNS mail proxy."
  use AutoDNS.Schema,
    fields: [
      :domain,
      :idn,
      :status,
      :target,
      :bannedFiles,
      :bannedFileAction,
      :virus,
      :virusAction,
      :spam,
      :spamAction,
      :spamLevel,
      :header,
      :greylisting,
      :owner,
      :updater,
      :created,
      :updated,
      :logId
    ]
end
