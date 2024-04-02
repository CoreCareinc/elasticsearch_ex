defmodule ElasticsearchEx.Guards do
  @moduledoc false

  ## Public guards

  defguard is_index(index)
           when (is_binary(index) and byte_size(index) > 0) or
                  (is_atom(index) and not is_nil(index))

  defguard is_document_id(document_id) when is_binary(document_id) and byte_size(document_id) > 0
end
