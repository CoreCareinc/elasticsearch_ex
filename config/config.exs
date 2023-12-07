import Config

if config_env() in ~w[dev test]a do
  # Define default any_http client adapter
  config :any_http, client_adapter: AnyHttp.Adapters.Httpc
end
