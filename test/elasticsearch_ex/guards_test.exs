defmodule ElasticsearchEx.GuardsTest do
  use ExUnit.Case, async: true

  import ElasticsearchEx.Guards

  describe "is_index/1" do
    test "with nil" do
      refute is_index(nil)
    end

    test "with an atom" do
      assert is_index(:index)
    end

    test "with a string" do
      assert is_index("index")
    end

    test "with an empty string" do
      refute is_index("")
    end
  end

  describe "is_document_id/1" do
    test "with nil" do
      refute is_document_id(nil)
    end

    test "with an atom" do
      refute is_document_id(:doc_id)
    end

    test "with a string" do
      assert is_document_id("doc_id")
    end

    test "with an empty string" do
      refute is_document_id("")
    end
  end
end
