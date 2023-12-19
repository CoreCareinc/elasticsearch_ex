defmodule ElasticsearchEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/CoreCareinc/elasticsearch_ex"
  @version "0.2.0"

  def project do
    [
      app: :elasticsearch_ex,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [debug_info: Mix.env() == :dev],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Elasticsearch_ex",
      description: "Elasticsearch_ex is a client library for Elasticsearch",
      docs: docs(),
      source_url: @source_url,
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElasticsearchEx.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :elasticsearch_ex,
      files: ["lib", "mix.exs"],
      maintainers: ["Geoffrey Roguelon"],
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  defp docs do
    [
      formatters: ["html"],
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      groups_for_modules: [
        API: [
          ElasticsearchEx.Api.Search.Core
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      list_unused_filters: true
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:any_http, "~> 0.2"},
      # Required because AnyHTTP uses :public_key.cacerts_get() which was introduced recently.
      {:castore, "~> 1.0", optional: true},
      {:jason, "~> 1.4"},

      ## Dev dependencies
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},

      ## Test dependencies
      {:bypass, "~> 2.1", only: :test},

      ## Dev & Test dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
