defmodule AutoDNS.Schema do
  @moduledoc false

  defmacro __using__(opts) do
    fields = Keyword.get(opts, :fields, [])

    quote do
      defstruct unquote(fields)

      @type t :: %__MODULE__{}

      @doc false
      def from_map(nil), do: nil

      def from_map(map) when is_map(map) do
        struct(__MODULE__, AutoDNS.Schema.atomize_keys(map))
      end

      @doc false
      def from_list(list) when is_list(list), do: Enum.map(list, &from_map/1)

      defoverridable from_map: 1
    end
  end

  @doc false
  def atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {safe_atom(k), atomize_value(v)}
      {k, v} -> {k, atomize_value(v)}
    end)
  end

  @doc false
  def atomize_value(map) when is_map(map), do: atomize_keys(map)
  def atomize_value(list) when is_list(list), do: Enum.map(list, &atomize_value/1)
  def atomize_value(value), do: value

  # Only convert to atom if it already exists — prevents atom table exhaustion
  # from attacker-controlled API response keys. Unknown keys are passed through
  # as strings; `struct/2` silently ignores non-field keys.
  defp safe_atom(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> key
  end
end
