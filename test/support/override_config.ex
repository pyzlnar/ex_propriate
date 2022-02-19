defmodule ExPropriate.Test.OverrideConfig do
  @moduledoc """
  This module is here to help override the application's config during unit testing.
  """

  @doc """
  This macro overrides the `enabled` value of the config.

  It needs to happen in a macro since the config is checked at compile time.
  """
  defmacro override_config_with(value) do
    Application.put_env(:ex_propriate, :enable, value)
  end
end
