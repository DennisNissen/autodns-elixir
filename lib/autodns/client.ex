defmodule AutoDNS.Client do
  @moduledoc """
  HTTP client for the AutoDNS JSON API.

  Handles request construction, authentication, and error handling.
  Create a client using `AutoDNS.client/3`.

  ## Example

      client = AutoDNS.client("user", "password")
      {:ok, response} = AutoDNS.Client.get(client, "/domain/example.com")

  """

  alias AutoDNS.{Error, Response}

  @type t :: %__MODULE__{
          username: String.t(),
          password: String.t(),
          base_url: String.t(),
          context: integer() | nil,
          auth_header: String.t(),
          opts: keyword()
        }

  defstruct [:username, :password, :base_url, :auth_header, context: nil, opts: []]

  @default_base_url "https://api.autodns.com/v1"

  @optional_header_map [
    owner_user: "x-domainrobot-owner-user",
    owner_context: "x-domainrobot-owner-context",
    session_id: "x-domainrobot-session-id",
    two_fa_token: "x-domainrobot-2fa-token",
    demo: "x-domainrobot-demo",
    websocket: "x-domainrobot-ws",
    bulk_limit: "x-domainrobot-bulk-limit"
  ]

  @doc false
  @spec new(String.t(), String.t(), keyword()) :: t()
  def new(username, password, opts \\ []) do
    base_url = Keyword.get(opts, :base_url, @default_base_url)
    context = Keyword.get(opts, :context)
    auth_header = "Basic " <> Base.encode64("#{username}:#{password}")

    %__MODULE__{
      username: username,
      password: password,
      base_url: base_url,
      context: context,
      auth_header: auth_header,
      opts: opts
    }
  end

  @doc """
  Performs a GET request.

  ## Parameters

  - `client` - The AutoDNS client
  - `path` - API path (e.g., `"/domain/example.com"`)
  - `params` - Optional query parameters as a keyword list

  """
  @spec get(t(), String.t(), keyword()) :: {:ok, Response.t()} | {:error, Error.t()}
  def get(client, path, params \\ []) do
    request(client, :get, path, nil, params)
  end

  @doc """
  Performs a POST request.

  ## Parameters

  - `client` - The AutoDNS client
  - `path` - API path
  - `body` - Request body as a map (will be JSON-encoded)
  - `params` - Optional query parameters

  """
  @spec post(t(), String.t(), map() | nil, keyword()) :: {:ok, Response.t()} | {:error, Error.t()}
  def post(client, path, body \\ nil, params \\ []) do
    request(client, :post, path, body, params)
  end

  @doc """
  Performs a PUT request.
  """
  @spec put(t(), String.t(), map() | nil, keyword()) :: {:ok, Response.t()} | {:error, Error.t()}
  def put(client, path, body \\ nil, params \\ []) do
    request(client, :put, path, body, params)
  end

  @doc """
  Performs a PATCH request.
  """
  @spec patch(t(), String.t(), map() | nil, keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def patch(client, path, body \\ nil, params \\ []) do
    request(client, :patch, path, body, params)
  end

  @doc """
  Performs a DELETE request.
  """
  @spec delete(t(), String.t(), map() | nil, keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def delete(client, path, body \\ nil, params \\ []) do
    request(client, :delete, path, body, params)
  end

  defp request(client, method, path, body, params) do
    req_opts =
      [
        method: method,
        url: client.base_url <> path,
        headers: build_headers(client)
      ]
      |> maybe_add_params(params)
      |> maybe_add_body(body)
      |> maybe_add_plug(client)

    case Req.request(Req.new(req_opts)) do
      {:ok, response} -> handle_response(response)
      {:error, exception} -> {:error, Error.from_exception(exception)}
    end
  end

  defp build_headers(client) do
    base = [
      {"authorization", client.auth_header},
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]

    base
    |> maybe_add_header("x-domainrobot-context", client.context)
    |> add_optional_headers(client.opts)
  end

  defp add_optional_headers(headers, opts) do
    Enum.reduce(@optional_header_map, headers, fn {opt_key, header_name}, acc ->
      maybe_add_header(acc, header_name, Keyword.get(opts, opt_key))
    end)
  end

  defp maybe_add_header(headers, _name, nil), do: headers
  defp maybe_add_header(headers, name, value), do: [{name, to_string(value)} | headers]

  defp maybe_add_params(req_opts, []), do: req_opts
  defp maybe_add_params(req_opts, params), do: Keyword.put(req_opts, :params, params)

  defp maybe_add_body(req_opts, nil), do: req_opts
  defp maybe_add_body(req_opts, body), do: Keyword.put(req_opts, :json, body)

  defp maybe_add_plug(req_opts, client) do
    case Keyword.get(client.opts, :plug) do
      nil -> req_opts
      plug -> Keyword.put(req_opts, :plug, plug)
    end
  end

  defp handle_response(%Req.Response{status: status, headers: headers, body: body})
       when status >= 200 and status < 300 do
    {:ok, Response.from_body(status, body, headers)}
  end

  defp handle_response(%Req.Response{} = response) do
    {:error, Error.from_response(%{status: response.status, body: response.body})}
  end
end
