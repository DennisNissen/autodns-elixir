defmodule AutoDNS.Response do
  @moduledoc """
  Wraps an HTTP response from the AutoDNS API.

  The AutoDNS API returns responses in a standard envelope:

      %{
        "stid" => "...",
        "status" => %{"code" => "S0105", "text" => "...", "type" => "SUCCESS"},
        "object" => %{...},
        "data" => [...]
      }

  ## Fields

  - `:status` - HTTP status code (e.g., `200`, `201`)
  - `:body` - Full decoded JSON response body
  - `:headers` - Raw response headers
  - `:stid` - Server transaction ID from the response
  - `:data` - The `data` list from the response envelope (for list endpoints)
  - `:object` - The `object` map from the response envelope (for single-resource endpoints)

  """

  @type t :: %__MODULE__{
          status: integer(),
          body: map() | list() | binary() | nil,
          headers: list() | map(),
          stid: String.t() | nil,
          data: list() | nil,
          object: map() | nil
        }

  defstruct [:status, :body, :headers, :stid, :data, :object]

  @doc false
  @spec from_body(integer(), map() | list() | binary() | nil, list() | map()) :: t()
  def from_body(status, body, headers) when is_map(body) do
    %__MODULE__{
      status: status,
      body: body,
      headers: headers,
      stid: body["stid"],
      data: body["data"],
      object: body["object"]
    }
  end

  def from_body(status, body, headers) do
    %__MODULE__{
      status: status,
      body: body,
      headers: headers
    }
  end
end
