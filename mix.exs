defmodule ExPropriate.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_propriate,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths:   elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "ExPropriate",
      source_url: "https://github.com/pyzlnar/ex_propriate",
      docs: [
        main:       "readme",
        source_ref: "master",
        extras:     ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Load extra paths when on test
  defp elixirc_paths(:test),   do: ~W[lib test/support]
  defp elixirc_paths(_normal), do: ~W[lib]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo,    "~> 1.6",  only: :dev, runtime: false},
      {:dialyxir, "~> 1.0",  only: :dev, runtime: false},
      {:ex_doc,   "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
