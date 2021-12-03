defmodule CheckerCab.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :checker_cab,
      version: @version,
      elixir: "~> 1.11.2",
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
      description: "TODO",
      links: %{"GitHub" => "https://github.com/Shimmur/checker_cab"}
    ]
  end

  defp deps do
    [
      # Dev and test dependencies.
      {:ecto, "~> 3.7"},
      {:ex_doc, "~> 0.20", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test},
      {:linter, "~> 1.1", organization: "community", only: [:dev, :test], runtime: false}
    ]
  end
end
