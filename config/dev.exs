import Config

# Define default any_http client adapter
config :any_http, client_adapter: AnyHttp.Adapters.Httpc

config :elasticsearch_ex, url: "https://elastic:elastic@localhost:9200"

config :mix_test_watch, clear: true
