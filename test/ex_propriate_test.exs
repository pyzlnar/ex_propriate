defmodule ExPropriateTest do
  use ExUnit.Case, async: true

  alias ExPropriate.Test.{ExpropriateAll, ExpropriateNone, MarkedFunctions}

  describe "w/config enabled: true and expropriate_all: true" do
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

    test "with do and rescue" do
      assert %RuntimeError{} = ExpropriateAll.with_do_and_rescue
    end
  end

  describe "w/config enabled: true and expropriate_all: false" do
    test "doesn't affect public functions" do
      assert ExpropriateNone.public_function == :am_public
    end

    test "with zero arity functions" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_zero_arity end

      assert ExpropriateNone.public_with_zero_arity == :zero_arity
    end

    test "with arity more than zero" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_one_arg(:my_value) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_one_arg("my_value") end

      assert ExpropriateNone.public_with_one_arg(:my_value)  == :my_value
      assert ExpropriateNone.public_with_one_arg("my_value") == "my_value"
    end

    test "with multiple_bodies" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_multiple_bodies(:one) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_multiple_bodies(:two) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_multiple_bodies(:three) end

      assert ExpropriateNone.public_with_multiple_bodies(:one)   == :body_one
      assert ExpropriateNone.public_with_multiple_bodies(:two)   == :body_two
      assert ExpropriateNone.public_with_multiple_bodies(:three) == :three
    end

    test "with guards" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_guards(3) end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_guards(0) end

      assert ExpropriateNone.public_with_guards(3) == 27
      assert ExpropriateNone.public_with_guards(0) == 0
    end

    test "with function head" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_function_head(:taste, what: "tacos") end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_function_head(:eat, what: "tacos") end

      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_function_head(:eat) end

      assert ExpropriateNone.public_with_function_head(:taste, what: "tacos") == "taste the rainbow"
      assert ExpropriateNone.public_with_function_head(:eat,   what: "tacos") == "eat tacos"
      assert ExpropriateNone.public_with_function_head(:eat)                  == "eat nothing"
    end

    test "with do and rescue" do
      assert_raise UndefinedFunctionError,
        fn -> ExpropriateNone.with_do_and_rescue end

      assert %RuntimeError{} = ExpropriateNone.public_with_do_and_rescue
    end
  end

  describe "w/config enabled: true and marked functions" do
    test "doesn't affect public functions" do
      assert MarkedFunctions.public_function            == :am_public
      assert MarkedFunctions.public_function_in_between == :am_private
    end

    test "with zero arity functions" do
      assert MarkedFunctions.with_zero_arity == :zero_arity
    end

    test "with arity more than zero" do
      assert MarkedFunctions.with_one_arg(:my_value)  == :my_value
      assert MarkedFunctions.with_one_arg("my_value") == "my_value"
    end

    test "with multiple_bodies" do
      assert MarkedFunctions.with_multiple_bodies(:one)   == :body_one
      assert MarkedFunctions.with_multiple_bodies(:two)   == :body_two
      assert MarkedFunctions.with_multiple_bodies(:three) == :three
    end

    test "with guards" do
      assert MarkedFunctions.with_guards(3) == 27
      assert MarkedFunctions.with_guards(0) == 0
    end

    test "with function head" do
      assert MarkedFunctions.with_function_head(:taste, what: "tacos") == "taste the rainbow"
      assert MarkedFunctions.with_function_head(:eat,   what: "tacos") == "eat tacos"
      assert MarkedFunctions.with_function_head(:eat)                  == "eat nothing"
    end

    test "with do and rescue" do
      assert %RuntimeError{} = MarkedFunctions.with_do_and_rescue
    end

    test "unexpropriaated functions" do
      assert_raise UndefinedFunctionError,
        fn -> MarkedFunctions.private_function_in_between end
    end
  end
end
