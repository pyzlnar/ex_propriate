defmodule ExPropriate.MixProject do
  use Mix.Project

  @version     "0.1.0"
  @project_url "https://github.com/pyzlnar/ex_propriate"

  def project do
    [
      app:             :ex_propriate,
      name:            "ExPropriate",
      version:         @version,
      elixir:          "~> 1.9",
      elixirc_paths:   elixirc_paths(Mix.env),
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps:            deps(),
      docs:            docs(),
      package:         package(),
      homepage_url:    @project_url,
      source_url:      @project_url,
      description:     "An Elixir library that allows you to decide whether or not a function is public at compile time."
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

  # Doc related info
  defp docs do
    [
      main:       "readme",
      source_ref: "master",
      extras:     ["README.md"]
    ]
  end

  # Hex package related info
  defp package do
    [
      licenses:    ["MIT"],
      maintainers: ["pyzlnar"],
      links: %{
        "GitHub" => @project_url
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo,    "~> 1.6",  only: :dev, runtime: false},
      {:dialyxir, "~> 1.0",  only: :dev, runtime: false},
      {:ex_doc,   "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
