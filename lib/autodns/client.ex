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
          opts: keyword()
        }

  defstruct [:username, :password, :base_url, context: nil, opts: []]

  @default_base_url "https://api.autodns.com/v1"

  @doc false
  @spec new(String.t(), String.t(), keyword()) :: t()
  def new(username, password, opts \\ []) do
    base_url = Keyword.get(opts, :base_url, @default_base_url)
    context = Keyword.get(opts, :context)

    %__MODULE__{
      username: username,
      password: password,
      base_url: base_url,
      context: context,
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

  # -- Private --

  defp request(client, method, path, body, params) do
    url = client.base_url <> path

    req_opts =
      [
        method: method,
        url: url,
        headers: build_headers(client)
      ]
      |> maybe_add_params(params)
      |> maybe_add_body(body)
      |> maybe_add_plug(client)

    try do
      response = Req.request!(Req.new(req_opts))
      handle_response(response)
    rescue
      e -> {:error, Error.from_exception(e)}
    end
  end

  defp build_headers(client) do
    credentials = Base.encode64("#{client.username}:#{client.password}")

    headers = [
      {"authorization", "Basic #{credentials}"},
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]

    headers
    |> maybe_add_header("x-domainrobot-context", client.context)
    |> maybe_add_header(
      "x-domainrobot-owner-user",
      Keyword.get(client.opts, :owner_user)
    )
    |> maybe_add_header(
      "x-domainrobot-owner-context",
      Keyword.get(client.opts, :owner_context)
    )
    |> maybe_add_header(
      "x-domainrobot-session-id",
      Keyword.get(client.opts, :session_id)
    )
    |> maybe_add_header(
      "x-domainrobot-2fa-token",
      Keyword.get(client.opts, :two_fa_token)
    )
    |> maybe_add_header("x-domainrobot-demo", Keyword.get(client.opts, :demo))
    |> maybe_add_header("x-domainrobot-ws", Keyword.get(client.opts, :websocket))
    |> maybe_add_header(
      "x-domainrobot-bulk-limit",
      Keyword.get(client.opts, :bulk_limit)
    )
  end

  defp maybe_add_header(headers, _name, nil), do: headers

  defp maybe_add_header(headers, name, value),
    do: [{name, to_string(value)} | headers]

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
