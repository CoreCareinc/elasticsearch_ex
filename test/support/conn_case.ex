defmodule ElasticsearchEx.ConnCase do
  @moduledoc """
  Provides a base to test the HTTP adapters
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import ElasticsearchEx.ConnCase
    end
  end

  setup_all do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end
end
