defmodule ExPropriate.Test.MarkedFunctions do
  @moduledoc """
  This module tests expropriating marked functions only.
  Only marked functions in here should be public.
  """

  import ExPropriate.Test.OverrideConfig
  override_config_with(true)

  use ExPropriate

  def public_function,
    do: :am_public

  @expropriate true
  defp with_zero_arity,
    do: :zero_arity

  @expropriate true
  defp with_one_arg(arg1),
    do: arg1

  def public_function_in_between,
    do: private_function_in_between()

  @expropriate true
  defp with_multiple_bodies(:one),  do: :body_one
  defp with_multiple_bodies(:two),  do: :body_two
  defp with_multiple_bodies(other), do: other

  @expropriate true
  defp with_guards(arg) when is_integer(arg) and arg > 0 do
    arg ** arg
  end

  defp with_guards(arg) do
    arg
  end

  defp private_function_in_between,
    do: :am_private

  @expropriate true
  defp with_function_head(verb \\ :taste, opts \\ [])

  defp with_function_head(:taste, _opts) do
    "taste the rainbow"
  end

  defp with_function_head(verb, opts) do
    what = Keyword.get(opts, :what, "nothing")
    "#{verb} #{what}"
  end

  @expropriate true
  defp with_do_and_rescue do
    raise "Something happened"
  rescue
    error -> error
  end
end
