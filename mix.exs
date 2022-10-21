defmodule CheckerCab.MixProject do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :checker_cab,
      version: @version,
      elixir: "~> 1.11",
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
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      organization: "community",
      description: "Test assertion helpers including assert_values_for",
      links: %{"GitHub" => "https://github.com/Shimmur/checker_cab"},
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jeffrey Matthias", "Geoff Smith"],
      organization: "community",
      licenses: ["MIT"]
    ]
  end

  defp deps do
    [
      # Dev and test dependencies.
      {:ecto, "~> 3.7"},
      {:ex_doc, "~> 0.20", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end
end
