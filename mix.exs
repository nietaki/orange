defmodule Orange.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :orange,
      deps: deps(),
      docs: docs(),
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test, test: :test],
      source_url: "https://github.com/nietaki/orange",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.4", only: :test},
      {:ex_doc, "~> 0.18", only: :dev},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(env) when is_atom(env), do: ["lib"]

  defp package do
    [
      licenses: ["Apache License 2.0"],
      maintainers: ["Jacek Królikowski <hello@nietaki.com>"],
      links: %{
        "GitHub" => "https://github.com/nietaki/orange"
      },
      description: description()
    ]
  end

  defp description do
    """
    Orange is a library for more powerful ranges than the Elixir language
    offers. Includes ranges operating on floating and decimal values,
    non-default step values and creating ranges over custom data types.
    """
  end

  defp aliases do
    []
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/nietaki/orange",
      extras: ["README.md"],
      assets: ["assets"]
      # logo: "assets/orange.png"
    ]
  end
end
