defmodule ElasticsearchExTest do
  use ExUnit.Case
  doctest ElasticsearchEx

  test "greets the world" do
    assert ElasticsearchEx.hello() == :world
  end
end
