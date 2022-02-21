defmodule ExPropriate do
  @moduledoc """
  ExPropriate is an Elixir library that allows you to decide whether or not a function is public at
  compile time.

  First you have to set up your configuration for `test` and any other environment you wish your
  functions to be expropriated in like this:

  ```elixir
  # config/test.exs
  config ExPropriate,
    enable: true
  ```

  It may also be useful to configure your `dev` environment like this, so you can test expropriated
  functions in console.

  ```elixir
  # config/dev.exs
  config ExPropriate,
    enable: System.get_env("EXPROPRIATE_ENABLED") == "true"
  ```

  ```bash
  EXPROPRIATE_ENABLED=true iex -S mix
  iex>
  ```

  Once your config is setup, you can start using ExPropriate in your modules. There are two ways
  in which it can be used:

  - Module level granularity via `ExPropriate.FullModule`
  - Function level granularity via `ExPropriate.MarkedFunctions`
  """

  alias ExPropriate.{FullModule, MarkedFunctions}

  defmacro __using__(opts \\ []) do
    from_config = Application.get_env(:ex_propriate, :enable, false)
    from_module = Keyword.get(opts, :expropriate_all, nil)

    # This setting is just for internal unit test purposes.
    from_config = Keyword.get(opts, :override_config_with) || from_config

    case {from_config, from_module} do
      # Expropriate full module
      {true, true} ->
        FullModule.generate_use_ast
      # Expropriate marked functions
      {true, nil} ->
        MarkedFunctions.generate_use_ast
      # Cleans up attributes to not raise any warnings with the unused @expropriate attrs.
      {false, nil} ->
        MarkedFunctions.generate_unused_ast
      # Don't do anything~
      _ ->
        nil
    end
  end
end
