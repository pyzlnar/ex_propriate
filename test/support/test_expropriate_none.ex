defmodule ExPropriate.Test.ExpropriateNone do
  @moduledoc """
  This module tests the expropriate_all: true option.
  All the private functions in this module should remain public.
  """

  import ExPropriate.Test.OverrideConfig
  override_config_with(true)

  use ExPropriate,
    expropriate_all: false

  # -- Public Interface -- #

  def public_function,
    do: :am_public

  def public_with_zero_arity,
    do: with_zero_arity()

  def public_with_one_arg(arg),
    do: with_one_arg(arg)

  def public_with_multiple_bodies(arg),
    do: with_multiple_bodies(arg)

  def public_with_guards(arg),
    do: with_guards(arg)

  def public_with_function_head(:taste),
    do: with_function_head()

  def public_with_function_head(arg1, arg2 \\ []),
    do: with_function_head(arg1, arg2)

  def public_with_do_and_rescue,
    do: with_do_and_rescue()

  # -- Private -- #

  defp with_zero_arity,
    do: :zero_arity

  defp with_one_arg(arg1),
    do: arg1

  defp with_multiple_bodies(:one),  do: :body_one
  defp with_multiple_bodies(:two),  do: :body_two
  defp with_multiple_bodies(other), do: other

  defp with_guards(arg) when is_integer(arg) and arg > 0 do
    arg ** arg
  end

  defp with_guards(arg) do
    arg
  end

  defp with_function_head(verb \\ :taste, opts \\ [])

  defp with_function_head(:taste, _opts) do
    "taste the rainbow"
  end

  defp with_function_head(verb, opts) do
    what = Keyword.get(opts, :what, "nothing")
    "#{verb} #{what}"
  end

  defp with_do_and_rescue do
    raise "Something happened"
  rescue
    error -> error
  end
end
