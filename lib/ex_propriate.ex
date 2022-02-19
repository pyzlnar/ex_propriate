defmodule ExPropriate do
  alias ExPropriate.{MarkedFunctions, FullModule}

  defmacro __using__(opts \\ []) do
    from_config = Application.get_env(:ex_propriate, :enable, false)
    from_module = Keyword.get(opts, :expropriate_all, nil)

    case {from_config, from_module} do
      # Expropriate full module
      {true, true} ->
        FullModule.generate_use_ast(opts)
      # Expropriate marked functions
      {true, nil} ->
        MarkedFunctions.generate_use_ast(opts)
      # Cleans up attributes to not raise any warnings with the unused @expropriate attrs.
      {false, nil} ->
        MarkedFunctions.generate_unused_ast
      # Don't do anything~
      _ ->
        nil
    end
  end
end
