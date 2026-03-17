defmodule AutoDNS.SubjectProducts do
  @moduledoc """
  Operations on AutoDNS subject products.

  ## Example

      {:ok, products} = AutoDNS.SubjectProducts.list(client)

  """

  alias AutoDNS.Client

  @doc "Searches for subject products."
  @spec list(Client.t(), map()) ::
          {:ok, [AutoDNS.SubjectProduct.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    with {:ok, response} <- Client.post(client, "/subjectProduct/_search", query) do
      {:ok, AutoDNS.SubjectProduct.from_list(response.data || [])}
    end
  end
end
