defmodule ElasticsearchEx.Api.Search.CoreTest do
  use ElasticsearchEx.ConnCase, async: true

  alias ElasticsearchEx.Api.Search.Core, as: Search

  ## Module attributes

  @index_name "test_api_search_core"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})

    {:ok, doc_ids: index_documents(@index_name, 3)}
  end

  describe "search/2 with POST method" do
    test "returns a sucessful response without an index", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => _, "total" => _},
                "hits" => %{
                  "hits" => [
                    %{
                      "_id" => ^doc_id,
                      "_index" => @index_name,
                      "_score" => 1.0,
                      "_source" => %{"message" => "Hello World 1!"}
                    }
                  ],
                  "max_score" => 1.0,
                  "total" => %{"relation" => "eq", "value" => 1}
                },
                "timed_out" => false,
                "took" => _took
              }} = Search.search(%{query: %{term: %{_id: doc_id}}, size: 1})
    end

    test "returns a sucessful response with an index", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 1, "total" => 1},
                "hits" => %{
                  "hits" => [
                    %{
                      "_id" => ^doc_id,
                      "_index" => @index_name,
                      "_score" => 1.0,
                      "_source" => %{"message" => "Hello World 1!"}
                    }
                  ],
                  "max_score" => 1.0,
                  "total" => %{"relation" => "eq", "value" => 1}
                },
                "timed_out" => false,
                "took" => _took
              }} = Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, index: @index_name)
    end
  end

  describe "search/2 returning an error" do
    @fake_index %{
      "index" => "fake",
      "index_uuid" => "_na_",
      "reason" => "no such index [fake]",
      "resource.id" => "fake",
      "resource.type" => "index_or_alias",
      "root_cause" => [
        %{
          "index" => "fake",
          "index_uuid" => "_na_",
          "reason" => "no such index [fake]",
          "resource.id" => "fake",
          "resource.type" => "index_or_alias",
          "type" => "index_not_found_exception"
        }
      ],
      "type" => "index_not_found_exception"
    }

    test "returns an error if wrong index" do
      assert {:error,
              %ElasticsearchEx.Error{
                reason: @fake_index["reason"],
                root_cause: @fake_index["root_cause"],
                status: 404,
                type: @fake_index["type"],
                original: @fake_index
              }} == Search.search(%{query: %{match_all: %{}}, size: 1}, index: :fake)
    end
  end
end
