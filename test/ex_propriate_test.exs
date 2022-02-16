defmodule TestModules.ExpropriateAll do
  use ExPropriate, expropriate_all: true

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
end

defmodule TestModules.ExpropriateNone do
  use ExPropriate, expropriate_all: false

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

  Kernel.defp this_is_a_test, do: :test
end

defmodule ExPropriateTest do
  use ExUnit.Case

  alias TestModules.{ExpropriateAll, ExpropriateNone}

  describe "with expropriate_all: true" do
    test "doesn't affect public functions" do
      assert ExpropriateAll.public_function == :am_public
    end

    test "with zero arity functions" do
      assert ExpropriateAll.with_zero_arity == :zero_arity
    end

    test "with arity more than zero" do
      assert ExpropriateAll.with_one_arg(:my_value)  == :my_value
      assert ExpropriateAll.with_one_arg("my_value") == "my_value"
    end

    test "with multiple_bodies" do
      assert ExpropriateAll.with_multiple_bodies(:one)   == :body_one
      assert ExpropriateAll.with_multiple_bodies(:two)   == :body_two
      assert ExpropriateAll.with_multiple_bodies(:three) == :three
    end

    test "with guards" do
      assert ExpropriateAll.with_guards(3) == 27
      assert ExpropriateAll.with_guards(0) == 0
    end

    test "with function head" do
      assert ExpropriateAll.with_function_head(:taste, what: "tacos") == "taste the rainbow"
      assert ExpropriateAll.with_function_head(:eat,   what: "tacos") == "eat tacos"
      assert ExpropriateAll.with_function_head(:eat)                  == "eat nothing"
    end
  end

  describe "with expropriate_all: false" do
    test "doesn't affect public functions" do
      assert ExpropriateNone.public_function == :am_public
    end

    test "with zero arity functions" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_zero_arity end
    end

    test "with arity more than zero" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_one_arg(:my_value) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_one_arg("my_value") end
    end

    test "with multiple_bodies" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_multiple_bodies(:one) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_multiple_bodies(:two) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_multiple_bodies(:three) end
    end

    test "with guards" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_guards(3) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_guards(0) end
    end

    test "with function head" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_function_head(:taste, what: "tacos") end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_function_head(:eat, what: "tacos") end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_function_head(:eat) end
    end
  end
end
