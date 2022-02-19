defmodule ExPropriate.MarkedFunctions do
  @moduledoc """
  This module handles expropiation of function-level granularity.

  It can be setup like this:

  ```elixir
  defmodule MyModule do
    use ExPropriate

    # Function becomes public
    @expropriate true
    defp expropriated_function,
      do: :am_expropriated

    # Functions with multiple bodies only need to be tagged on the first body
    @expropriate true
    defp divide_by(number) when is_integer(number) and number > 0,
      do: {:ok, div(100, number)}

    defp divide_by(_other),
      do: :error

    # Untagged functions remain private
    @expropriate false
    defp remains_private,
      do: :am_private
  end

  MyModule.expropriated_function
  # :am_expropriated

  MyModule.divide_by(2)
  # { :ok, 50 }

  MyModule.divide_by(0)
  # :error

  MyModule.remains_private
  # (UndefinedFunctionError) function MyModule.remains_private/0 is undefined or private.
  ```

  The objective of this module was to be able to explicitly state which functions need to be
  expropriated. The tradeoff is that this module is more "_intrusive_" than the module-level
  granularity, since it overrides both `Kernel.def/2` and `Kernel.defp/2`.

  Also a friendly reminder that the functions and macros contained in this module are for internal
  use of the library and it's advised _against_ using them directly.
  """

  @typedoc """
  Tuple containing a function's name an arity.
  """
  @type fn_name :: {name :: atom, arity :: non_neg_integer}

  @doc """
  Generates ast to inject this module's `def/2` and `defp/2` macro instead of
  `Kernel.def/2` and `Kernel.defp/2`.
  """
  @spec generate_use_ast(keyword) :: Macro.t
  def generate_use_ast(_opts) do
    quote do
      import Kernel, except: [def: 1, def: 2, defp: 1, defp: 2]
      import unquote(__MODULE__), only: [def: 1, def: 2, defp: 1, defp: 2]

      @expropriate false
      Module.register_attribute __MODULE__, :expropriated_names, accumulate: true
    end
  end

  @doc """
  Generates ast to prevent warnings on unused `@expropriate` attributes.

  These warnings would happen when the module include the `@expropriate` attributes, but ExPropriate
  is disabled at a config level. Eg: in prod.
  """
  def generate_unused_ast do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Module.delete_attribute __MODULE__, :expropriate
    end
  end

  @doc """
  An override of `Kernel.def/2`.

  This macro checks if the `@expropriate` attribute was set to `true` before defining a public
  function, and outputs a warning if that's the case.

  Regardless of the warning, it _always_ defines the fuction using `Kernel.def/2`
  """
  defmacro def(fn_head, fn_body \\ nil) do
    quote do
      if @expropriate do
        @expropriate false
        IO.warn("You set @expropriate before a public function.", Macro.Env.stacktrace(__ENV__))
      end
      unquote(__MODULE__.define_public(fn_head, fn_body))
    end
  end

  @doc """
  An override of `Kernel.defp/2`.

  This macro decides whether or not the expropriate the function body based on the following
  criteria:

  * The `@expropriate` attribute is set to `true`
  * The function's name (`{name, arity}`) was already expropriated. (For functions with multiple
    bodies)
  """
  defmacro defp(fn_head, fn_body \\ nil) do
    fn_name = fn_head_to_name(fn_head)
    quote do
      cond do
        @expropriate ->
          unquote(__MODULE__.define_first_public_body(fn_name, fn_head, fn_body))
        unquote(fn_name) in @expropriated_names ->
          unquote(__MODULE__.define_public(fn_head, fn_body))
        true ->
          unquote(__MODULE__.define_private(fn_head, fn_body))
      end
    end
  end

  @doc """
  Transforms a function's head AST into a tuple containing the name and arity of the function.

  **Examples**:

  ```elixir
  iex> quote do
  ...>   zero_arity()
  ...> end
  ...> |> fn_head_to_name()
  {:zero_arity, 0}

  iex> quote do
  ...>   with_two_arguments(arg1, arg2)
  ...> end
  ...> |> fn_head_to_name()
  {:with_two_arguments, 2}

  iex> quote do
  ...>   with_guards(arg) when is_atom(arg)
  ...> end
  ...> |> fn_head_to_name()
  {:with_guards, 1}
  ```
  """
  @spec fn_head_to_name(Macro.t) :: fn_name
  def fn_head_to_name({:when, _, [fn_head|_checks]}) do
    fn_head_to_name(fn_head)
  end

  def fn_head_to_name({name, _, nil}) when is_atom(name) do
    {name, 0}
  end

  def fn_head_to_name({name, _, args}) when is_atom(name) and is_list(args) do
    {name, Enum.count(args)}
  end

  def define_first_public_body(fn_name, fn_head, fn_body) do
    quote do
      @expropriate false
      @expropriated_names unquote(fn_name)
      unquote(__MODULE__.define_public(fn_head, fn_body))
    end
  end

  def define_public(fn_head, nil) do
    quote do
      Kernel.def unquote(fn_head)
    end
  end

  def define_public(fn_head, fn_body) do
    quote do
      Kernel.def unquote(fn_head), unquote(fn_body)
    end
  end

  def define_private(fn_head, nil) do
    quote do
      Kernel.defp unquote(fn_head)
    end
  end

  def define_private(fn_head, fn_body) do
    quote do
      Kernel.defp unquote(fn_head), unquote(fn_body)
    end
  end
end
