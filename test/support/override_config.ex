defmodule ExPropriate.Test.OverrideConfig do
  @doc """
  This macro just helps override the aplpication's config during unit testing.
  It needs to happen in a macro since the config is checked at compile time.
  """
  defmacro override_config_with(value) do
    Application.put_env(:ex_propriate, :enable, value)
  end
end
