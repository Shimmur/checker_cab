defmodule CheckerCab.MixProject do
  use Mix.Project

  @version "1.3.0"

  def project do
    [
      app: :checker_cab,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:ex_unit]
      ],
      docs: docs(),
      package: package(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "Test assertion helpers including assert_values_for",
      links: %{"GitHub" => "https://github.com/Shimmur/checker_cab"},
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jeffrey Matthias", "Geoff Smith"],
      licenses: ["MIT"]
    ]
  end

  defp deps do
    [
      # Dev and test dependencies.
      {:ecto, "~> 3.11"},
      {:ex_doc, "~> 0.31.2", only: :dev},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:decimal, "~> 2.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "readme",
      name: "CheckerCab",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end
end
