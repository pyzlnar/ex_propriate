defmodule ExPropriate.MarkedFunctionsTest do
  use ExUnit.Case, async: true

  alias ExPropriate.MarkedFunctions
  require MarkedFunctions

  describe "fn_head_to_name/1" do
    test "returns {:ok, {name, arity}} for valid function heads" do
      result = MarkedFunctions.fn_head_to_name(
        quote do
          zero_arity()
        end
      )
      assert result == {:ok, {:zero_arity, 0}}

      result = MarkedFunctions.fn_head_to_name(
        quote do
          with_two_arguments(arg1, arg2)
        end
      )
      assert result == {:ok, {:with_two_arguments, 2}}

      result = MarkedFunctions.fn_head_to_name(
        quote do
          with_guards(arg) when is_atom(arg)
        end
      )
      assert result == {:ok, {:with_guards, 1}}
    end

    test "returns :error for invalid function heads" do
      result = MarkedFunctions.fn_head_to_name(
        quote do
          :not_a_function_head
        end
      )
      assert result == :error
    end
  end

  describe "define_first_public_body/3" do
    test "returns an AST that sets the attributes and defines the function as public" do
      {:def, _, [fn_head, fn_body]} = quote do
        def my_function(arg1, arg2) do
          arg1 + arg2
        end
      end

      result =
        MarkedFunctions.define_first_public_body({:my_function, 2}, fn_head, fn_body)
        |> Macro.to_string

      assert result =~ ~r/@expropriate[( ]false\)?/
      assert result =~ ~r/@expropriated_names[( ]{:my_function, 2}\)?/
      assert result =~ ~r/def[( ]my_function\(arg1, arg2\)\)?/
      assert result =~ ~r/arg1 \+ arg2/
    end
  end

  describe "define_public/2" do
    test "returns an AST thae defines the function as public" do
      {:def, _, [fn_head, fn_body]} = quote do
        def my_function(arg1, arg2) do
          arg1 + arg2
        end
      end

      result =
        MarkedFunctions.define_public(fn_head, fn_body)
        |> Macro.to_string

      assert result =~ ~r/def[( ]my_function\(arg1, arg2\)\)?/
      assert result =~ ~r/arg1 \+ arg2/
    end
  end

  describe "define_private/2" do
    test "returns an AST thae defines the function as private" do
      {:def, _, [fn_head, fn_body]} = quote do
        def my_function(arg1, arg2) do
          arg1 + arg2
        end
      end

      result =
        MarkedFunctions.define_private(fn_head, fn_body)
        |> Macro.to_string

      assert result =~ ~r/defp[( ]my_function\(arg1, arg2\)\)?/
      assert result =~ ~r/arg1 \+ arg2/
    end
  end
end
