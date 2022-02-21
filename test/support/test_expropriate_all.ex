defmodule ExPropriate.Test.ExpropriateAll do
  @moduledoc """
  This module tests the expropriate_all: true option.
  All the private functions in this module should be public.
  """

  use ExPropriate,
    expropriate_all: true,
    override_config_with: true

  def public_function,
    do: :am_public

  defp with_zero_arity,
    do: :zero_arity

  defp with_one_arg(arg1),
    do: arg1

  defp with_multiple_bodies(:one),  do: :body_one
  defp with_multiple_bodies(:two),  do: :body_two
  defp with_multiple_bodies(other), do: other

  defp with_guards(arg) when is_integer(arg) and arg > 0 do
    arg * arg
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

  defp with_more_than_just_do(what) do
    case what do
      :raise ->
        raise "Something happened"
      :throw ->
        throw(:its_a_baseball)
      :else ->
        :oh_hey
    end
  rescue
    error -> error
  catch
    :its_a_baseball ->
      :home_run!
  else
    :oh_hey ->
      :big_zam
  end
end
