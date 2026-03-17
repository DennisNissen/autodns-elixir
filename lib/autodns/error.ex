defmodule AutoDNS.Error do
  @moduledoc """
  Represents an error returned by the AutoDNS API.

  ## Fields

  - `:status` - HTTP status code (e.g., `401`, `404`, `422`, `500`)
  - `:message` - Human-readable error message
  - `:body` - Raw response body (decoded JSON map or raw string)

  ## Common Error Statuses

  | Status | Meaning |
  |--------|---------|
  | `401`  | Unauthorized — invalid credentials |
  | `403`  | Forbidden — insufficient permissions |
  | `404`  | Not Found — resource does not exist |
  | `422`  | Unprocessable Entity — invalid request payload |
  | `500`  | Internal Server Error |

  """

  @type t :: %__MODULE__{
          status: integer() | nil,
          message: String.t(),
          body: map() | String.t() | nil
        }

  defexception [:status, :message, :body]

  @impl true
  def message(%__MODULE__{message: message}), do: message

  @doc false
  def from_response(%{status: status, body: body}) when status >= 400 do
    message = extract_message(body, status)
    %__MODULE__{status: status, message: message, body: body}
  end

  @doc false
  def from_exception(exception) do
    %__MODULE__{status: nil, message: Exception.message(exception), body: nil}
  end

  defp extract_message(%{"messages" => [%{"text" => text} | _]}, _status) when is_binary(text),
    do: text

  defp extract_message(%{"status" => %{"text" => text}}, _status) when is_binary(text), do: text
  defp extract_message(%{"message" => message}, _status) when is_binary(message), do: message
  defp extract_message(%{"error" => error}, _status) when is_binary(error), do: error
  defp extract_message(body, _status) when is_binary(body) and body != "", do: body
  defp extract_message(_body, status), do: "HTTP #{status}"
end
