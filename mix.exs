defmodule Edantic.MixProject do
  use Mix.Project

  def project do
    [
      app: :edantic,
      version: "0.1.1",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/savonarola/edantic",
      description: description(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.github": :test
      ],
      dialyzer: [
        plt_add_deps: true,
        flags: ["-Werror_handling", "-Wrace_conditions"]
      ]
    ]
  end

  defp description do
    "JSON casting and validation library based on Elixir type specifications"
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :edantic,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Ilya Averyanov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/savonarola/edantic"
      }
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
      {:excoveralls, "~> 0.18", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37", only: :dev},
      ## For excoveralls
      {:castore, "~> 1.0", only: [:dev, :test]}
    ]
  end
end
