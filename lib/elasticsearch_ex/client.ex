defmodule ElasticsearchEx.Client do
  @moduledoc """
  Provides the functions to make HTTP calls.
  """

  ## Module attributes

  @redact_auth Mix.env() == :prod

  @content_type_key "content-type"

  @application_json "application/json"

  @application_ndjson "application/x-ndjson"

  @default_headers %{@content_type_key => @application_json}

  ## Public functions

  def request(method, path, headers, body, opts \\ []) when is_list(opts) do
    {cluster, opts} = get_cluster_configuration(opts)

    Req.new(method: method, redact_auth: @redact_auth, compressed: true, compress_body: true)
    |> set_uri_and_userinfo(cluster, path)
    |> set_headers(cluster, headers)
    |> set_body(body)
    |> set_query_params(cluster, opts)
    |> Req.Request.append_request_steps(inspect: &IO.inspect/1)
    |> Req.request()
    |> parse_result()
  end

  def head(path, headers \\ nil, opts \\ []) do
    case request(:head, path, headers, nil, opts) do
      {:ok, nil} ->
        :ok

      {:error, %ElasticsearchEx.Error{}} ->
        :error
    end
  end

  def get(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:get, path, headers, body, opts)
  end

  def post(path, headers \\ nil, body \\ "", opts \\ []) do
    request(:post, path, headers, body, opts)
  end

  def put(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:put, path, headers, body, opts)
  end

  def delete(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:delete, path, headers, body, opts)
  end

  @doc false
  def json, do: %{@content_type_key => @application_json}

  @doc false
  def ndjson, do: %{@content_type_key => @application_ndjson}

  ## Private functions

  defp parse_result({:ok, %Req.Response{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp parse_result({:ok, %Req.Response{status: status} = response}) when status in 300..599 do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result({:error, error}) do
    raise "Unknown error: #{inspect(error)}"
  end

  defp get_cluster_configuration(opts) do
    {cluster, opts} = Keyword.pop(opts, :cluster, :default)

    if is_map(cluster) do
      {cluster, opts}
    else
      clusters_configuration = Application.fetch_env!(:elasticsearch_ex, :clusters)
      cluster_configuration = Map.fetch!(clusters_configuration, cluster)

      {cluster_configuration, opts}
    end
  end

  defp set_uri_and_userinfo(%Req.Request{} = req, cluster, path) do
    uri = cluster |> Map.fetch!(:endpoint) |> URI.new!() |> URI.merge(path)
    auth = uri.userinfo && {:basic, uri.userinfo}
    uri = %{uri | userinfo: nil}

    Req.merge(req, url: uri, auth: auth)
  end

  defp set_query_params(%Req.Request{} = req, cluster, opts) do
    global_req_opts = Map.get(cluster, :req_opts, [])
    {req_opts, query} = Keyword.pop(opts, :req_opts, [])
    req_opts = Keyword.merge(global_req_opts, req_opts)

    req |> Req.merge(params: query) |> Req.merge(req_opts)
  end

  defp set_headers(%Req.Request{} = req, cluster, headers) do
    headers =
      (Map.get(cluster, :headers) || %{})
      |> Map.merge(headers || @default_headers)
      |> Map.reject(fn {_key, value} -> is_nil(value) end)

    Req.merge(req, headers: headers)
  end

  defp set_body(%Req.Request{headers: %{@content_type_key => [@application_ndjson]}} = req, body) do
    Req.merge(req, body: ElasticsearchEx.Ndjson.encode!(body))
  end

  defp set_body(%Req.Request{headers: %{@content_type_key => [@application_json]}} = req, body) do
    Req.merge(req, json: body)
  end

  defp set_body(%Req.Request{} = req, body) do
    Req.merge(req, body: body)
  end
end
