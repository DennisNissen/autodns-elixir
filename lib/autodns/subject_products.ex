defmodule AutoDNS.SubjectProducts do
  @moduledoc """
  Operations on AutoDNS subject products.

  ## Example

      {:ok, products} = AutoDNS.SubjectProducts.list(client)

  """

  alias AutoDNS.{Client, Response, SubjectProduct}

  @doc "Searches for subject products."
  @spec list(Client.t(), map()) :: {:ok, [SubjectProduct.t()]} | {:error, AutoDNS.Error.t()}
  def list(client, query \\ %{}) do
    Client.post(client, "/subjectProduct/_search", query) |> Response.to_list(SubjectProduct)
  end
end
