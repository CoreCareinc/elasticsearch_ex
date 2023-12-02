defmodule ElasticsearchEx.Api.Search.Core do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  @default_headers %{content_type: "application/json"}

  @doc """
  Returns search hits that match the query defined in the request.
  """
  @spec search(map(), keyword()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def search(query, opts \\ []) when is_map(query) and is_list(opts) do
    method = Keyword.get(opts, :http_method, :post)
    url = Keyword.fetch!(opts, :url)
    body = Jason.encode_to_iodata!(query)

    Req.request(url, method: method, headers: @default_headers, body: body)
  end
end
