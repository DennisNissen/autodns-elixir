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

  @type result :: {:ok, t()} | {:error, AutoDNS.Error.t()}

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

  @doc """
  Maps a response `:ok` tuple through `module.from_map/1`, falling back to
  `body` if `object` is nil. Passes `:error` tuples through unchanged.

  Some AutoDNS endpoints (e.g. `GET /zone/{origin}`) return single resources
  as the first element of `data` rather than in `object`, so `data[0]` is
  preferred over the envelope body when `object` is absent.

      Client.get(client, "/domain/example.com")
      |> Response.to_struct(AutoDNS.Domain)

  """
  @spec to_struct(result(), module()) :: {:ok, struct() | nil} | {:error, AutoDNS.Error.t()}
  def to_struct({:ok, %__MODULE__{} = r}, module) do
    {:ok, module.from_map(single_resource(r))}
  end

  def to_struct({:error, _} = err, _module), do: err

  @doc """
  Maps a response `:ok` tuple through `module.from_list/1` on the response `data`.
  Passes `:error` tuples through unchanged.

      Client.post(client, "/domain/_search", query)
      |> Response.to_list(AutoDNS.Domain)

  """
  @spec to_list(result(), module()) :: {:ok, [struct()]} | {:error, AutoDNS.Error.t()}
  def to_list({:ok, %__MODULE__{data: data}}, module) do
    {:ok, module.from_list(data || [])}
  end

  def to_list({:error, _} = err, _module), do: err

  @doc """
  Unwraps a response to its single-resource map without struct conversion.

  Prefers `object`, then the first element of `data` (for endpoints that
  return a single resource inside a `data` array), then the raw `body`.
  """
  @spec object(result()) :: {:ok, map() | nil} | {:error, AutoDNS.Error.t()}
  def object({:ok, %__MODULE__{} = r}), do: {:ok, single_resource(r)}
  def object({:error, _} = err), do: err

  @doc "Unwraps a response to the raw `data` list."
  @spec data(result()) :: {:ok, list()} | {:error, AutoDNS.Error.t()}
  def data({:ok, %__MODULE__{data: data}}), do: {:ok, data || []}
  def data({:error, _} = err), do: err

  @doc "Unwraps a response to the raw response `body`."
  @spec body(result()) :: {:ok, map() | list() | binary() | nil} | {:error, AutoDNS.Error.t()}
  def body({:ok, %__MODULE__{body: body}}), do: {:ok, body}
  def body({:error, _} = err), do: err

  defp single_resource(%__MODULE__{object: object}) when is_map(object), do: object
  defp single_resource(%__MODULE__{data: [first | _]}) when is_map(first), do: first
  defp single_resource(%__MODULE__{body: body}), do: body
end
